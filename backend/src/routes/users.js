const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { requireAuth } = require('../middleware/clerkAuth');

const prisma = new PrismaClient();

// GET /api/users/me
router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/users/me
router.put('/me', requireAuth, async (req, res) => {
  const { displayName, bio, avatarUrl } = req.body;

  try {
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: {
        ...(displayName && { displayName }),
        ...(bio !== undefined && { bio }),
        ...(avatarUrl !== undefined && { avatarUrl }),
      },
    });

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/users/me/settings
router.get('/me/settings', requireAuth, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      select: { messagePrivacy: true },
    });

    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /api/users/me/settings
router.put('/me/settings', requireAuth, async (req, res) => {
  const { messagePrivacy } = req.body;
  const validPrivacy = ['EVERYONE', 'FRIENDS'];

  if (messagePrivacy && !validPrivacy.includes(messagePrivacy)) {
    return res.status(400).json({ error: 'Invalid messagePrivacy value' });
  }

  try {
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: { messagePrivacy },
    });

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/users/me/blocked
router.get('/me/blocked', requireAuth, async (req, res) => {
  try {
    const blocks = await prisma.block.findMany({
      where: { blockerId: req.userId },
      include: {
        blocked: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    res.json({ blocked: blocks.map((b) => b.blocked) });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/users/block
router.post('/block', requireAuth, async (req, res) => {
  const { targetUserId } = req.body;

  if (!targetUserId || targetUserId === req.userId) {
    return res.status(400).json({ error: 'Invalid target user' });
  }

  try {
    // Remove friendship if exists
    await prisma.friendship.deleteMany({
      where: {
        OR: [
          { userAId: req.userId, userBId: targetUserId },
          { userAId: targetUserId, userBId: req.userId },
        ],
      },
    });

    // Remove pending friend requests
    await prisma.friendRequest.deleteMany({
      where: {
        OR: [
          { senderId: req.userId, receiverId: targetUserId },
          { senderId: targetUserId, receiverId: req.userId },
        ],
      },
    });

    // Create block
    const block = await prisma.block.upsert({
      where: {
        blockerId_blockedId: {
          blockerId: req.userId,
          blockedId: targetUserId,
        },
      },
      update: {},
      create: {
        blockerId: req.userId,
        blockedId: targetUserId,
      },
    });

    res.json({ success: true, block });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/users/block/:userId
router.delete('/block/:userId', requireAuth, async (req, res) => {
  const { userId } = req.params;

  try {
    await prisma.block.delete({
      where: {
        blockerId_blockedId: {
          blockerId: req.userId,
          blockedId: userId,
        },
      },
    });

    res.json({ success: true });
  } catch (err) {
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Block not found' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/users/search?q=query
router.get('/search', requireAuth, async (req, res) => {
  const { q } = req.query;

  if (!q || q.trim().length < 2) {
    return res.status(400).json({ error: 'Query too short' });
  }

  try {
    // Get blocked user IDs to exclude
    const blocks = await prisma.block.findMany({
      where: {
        OR: [
          { blockerId: req.userId },
          { blockedId: req.userId },
        ],
      },
    });
    const blockedIds = new Set([
      ...blocks.map((b) => b.blockedId),
      ...blocks.map((b) => b.blockerId),
      req.userId,
    ]);

    const users = await prisma.user.findMany({
      where: {
        AND: [
          {
            OR: [
              { displayName: { contains: q, mode: 'insensitive' } },
              { username: { contains: q, mode: 'insensitive' } },
            ],
          },
          { id: { notIn: [...blockedIds] } },
        ],
      },
      select: {
        id: true,
        username: true,
        displayName: true,
        avatarUrl: true,
        bio: true,
      },
      take: 20,
    });

    // Enrich with friend status
    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [
          { userAId: req.userId },
          { userBId: req.userId },
        ],
      },
    });
    const friendIds = new Set(
      friendships.flatMap((f) => [f.userAId, f.userBId]).filter((id) => id !== req.userId)
    );

    const sentRequests = await prisma.friendRequest.findMany({
      where: { senderId: req.userId, status: 'PENDING' },
    });
    const sentRequestIds = new Set(sentRequests.map((r) => r.receiverId));

    const pendingRequests = await prisma.friendRequest.findMany({
      where: { receiverId: req.userId, status: 'PENDING' },
    });
    const pendingRequestIds = new Set(pendingRequests.map((r) => r.senderId));

    const enriched = users.map((u) => ({
      ...u,
      friendStatus: friendIds.has(u.id)
        ? 'accepted'
        : sentRequestIds.has(u.id)
        ? 'sent'
        : pendingRequestIds.has(u.id)
        ? 'pending'
        : 'none',
    }));

    res.json({ users: enriched });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/users/:userId (public profile)
router.get('/:userId', requireAuth, async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        displayName: true,
        avatarUrl: true,
        bio: true,
        createdAt: true,
      },
    });

    if (!user) return res.status(404).json({ error: 'User not found' });

    // Check if blocked
    const block = await prisma.block.findFirst({
      where: {
        OR: [
          { blockerId: req.userId, blockedId: userId },
          { blockerId: userId, blockedId: req.userId },
        ],
      },
    });

    if (block) return res.status(403).json({ error: 'User not available' });

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
