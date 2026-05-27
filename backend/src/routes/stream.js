const express = require('express');
const router = express.Router();
const { StreamChat } = require('stream-chat');
const { PrismaClient } = require('@prisma/client');
const { requireAuth } = require('../middleware/clerkAuth');

const prisma = new PrismaClient();

const streamClient = new StreamChat(
  process.env.STREAM_API_KEY,
  process.env.STREAM_API_SECRET
);

// POST /api/stream/token - Generate Stream Chat user token
router.post('/token', requireAuth, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
    });

    if (!user) return res.status(404).json({ error: 'User not found' });

    // Upsert user in Stream
    await streamClient.upsertUser({
      id: req.userId,
      name: user.displayName,
      image: user.avatarUrl,
    });

    const token = streamClient.createToken(req.userId);
    res.json({ token, userId: req.userId });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
