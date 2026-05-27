const express = require('express');
const router = express.Router();
const { clerkClient } = require('@clerk/clerk-sdk-node');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// POST /api/auth/sign-up
// Creates a Clerk user + syncs to our DB
router.post('/sign-up', async (req, res) => {
  const { email, password, username, displayName } = req.body;

  if (!email || !password || !username || !displayName) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  // Basic validation
  if (password.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters' });
  }
  if (!/^[a-zA-Z0-9_]+$/.test(username)) {
    return res.status(400).json({ error: 'Username can only contain letters, numbers, and underscores' });
  }

  try {
    // Check if username is taken in our DB
    const existingUser = await prisma.user.findUnique({
      where: { username: username.toLowerCase() },
    });
    if (existingUser) {
      return res.status(409).json({ error: 'Username already taken' });
    }

    // Create user in Clerk
    const clerkUser = await clerkClient.users.createUser({
      emailAddress: [email],
      password,
      firstName: displayName.split(' ')[0],
      lastName: displayName.split(' ').slice(1).join(' ') || undefined,
      username: username.toLowerCase(),
    });

    // Sync to our database
    const dbUser = await prisma.user.create({
      data: {
        id: clerkUser.id,
        email,
        username: username.toLowerCase(),
        displayName,
        avatarUrl: clerkUser.imageUrl,
        messagePrivacy: 'FRIENDS',
      },
    });

    // Create a sign-in session to get a token
    const signInToken = await clerkClient.signInTokens.createSignInToken({
      userId: clerkUser.id,
      expiresInSeconds: 60 * 60 * 24 * 7, // 7 days
    });

    res.status(201).json({
      token: signInToken.token,
      user: dbUser,
    });
  } catch (err) {
    if (err.errors) {
      const clerkError = err.errors[0];
      return res.status(422).json({ error: clerkError.longMessage || clerkError.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/sign-in
router.post('/sign-in', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Look up the user by email
    const users = await clerkClient.users.getUserList({ emailAddress: [email] });

    if (!users.data || users.data.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const clerkUser = users.data[0];

    // Verify password via Clerk
    const verifyResult = await clerkClient.users.verifyPassword({
      userId: clerkUser.id,
      password,
    });

    if (!verifyResult.verified) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Ensure user exists in our DB
    let dbUser = await prisma.user.findUnique({
      where: { id: clerkUser.id },
    });

    if (!dbUser) {
      // Auto-sync if user exists in Clerk but not in our DB
      dbUser = await prisma.user.create({
        data: {
          id: clerkUser.id,
          email,
          username: clerkUser.username || email.split('@')[0],
          displayName: `${clerkUser.firstName || ''} ${clerkUser.lastName || ''}`.trim() || email.split('@')[0],
          avatarUrl: clerkUser.imageUrl,
        },
      });
    }

    // Create session token
    const signInToken = await clerkClient.signInTokens.createSignInToken({
      userId: clerkUser.id,
      expiresInSeconds: 60 * 60 * 24 * 7,
    });

    res.json({
      token: signInToken.token,
      user: dbUser,
    });
  } catch (err) {
    if (err.errors) {
      const clerkError = err.errors[0];
      return res.status(422).json({ error: clerkError.longMessage || clerkError.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/webhook - Clerk webhook for user events
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const svixId = req.headers['svix-id'];
  const svixTimestamp = req.headers['svix-timestamp'];
  const svixSignature = req.headers['svix-signature'];

  if (!svixId || !svixTimestamp || !svixSignature) {
    return res.status(400).json({ error: 'Missing Svix headers' });
  }

  const { Webhook } = require('svix');
  const wh = new Webhook(process.env.CLERK_WEBHOOK_SECRET);

  let evt;
  try {
    evt = wh.verify(req.body, {
      'svix-id': svixId,
      'svix-timestamp': svixTimestamp,
      'svix-signature': svixSignature,
    });
  } catch (err) {
    return res.status(400).json({ error: 'Invalid signature' });
  }

  const { type, data } = evt;

  if (type === 'user.updated') {
    await prisma.user.updateMany({
      where: { id: data.id },
      data: {
        email: data.email_addresses[0]?.email_address,
        avatarUrl: data.image_url,
        displayName: `${data.first_name || ''} ${data.last_name || ''}`.trim() || data.username,
      },
    });
  }

  if (type === 'user.deleted') {
    await prisma.user.deleteMany({ where: { id: data.id } });
  }

  res.json({ received: true });
});

module.exports = router;
