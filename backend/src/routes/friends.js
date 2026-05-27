const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { requireAuth } = require('../middleware/clerkAuth');

const prisma = new PrismaClient();

// GET /api/friends
router.get('/', requireAuth, async (req, res) => {
  try {
    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [{ userAId: req.userId }, { userBId: req.userId }],
      },
      include: {
        userA: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
            bio: true,
          },
        },
        userB: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
            bio: true,
          },
        },
      },
    });

    const friends = friendships.map((f) => {
      const friend = f.userAId === req.userId ? f.userB : f.userA;
      return { ...friend, isOnline: false, friendStatus: 'accepted' };
    });

    res.json({ friends });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/friends/requests/incoming
router.get('/requests/incoming', requireAuth, async (req, res) => {
  try {
    const requests = await prisma.friendRequest.findMany({
      where: { receiverId: req.userId, status: 'PENDING' },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      requests: requests.map((r) => ({
        id: r.id,
        sender: r.sender,
        createdAt: r.createdAt,
      })),
    });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/friends/requests/outgoing
router.get('/requests/outgoing', requireAuth, async (req, res) => {
  try {
    const requests = await prisma.friendRequest.findMany({
      where: { senderId: req.userId, status: 'PENDING' },
      include: {
        receiver: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    res.json({ requests });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/friends/request
router.post('/request', requireAuth, async (req, res) => {
  const { targetUserId } = req.body;

  if (!targetUserId || targetUserId === req.userId) {
    return res.status(400).json({ error: 'Invalid target user' });
  }

  try {
    // Check if already friends
    const existing = await prisma.friendship.findFirst({
      where: {
        OR: [
          { userAId: req.userId, userBId: targetUserId },
          { userAId: targetUserId, userBId: req.userId },
        ],
      },
    });
    if (existing) return res.status(409).json({ error: 'Already friends' });

    // Check if target user blocked current user
    const block = await prisma.block.findFirst({
      where: {
        OR: [
          { blockerId: targetUserId, blockedId: req.userId },
          { blockerId: req.userId, blockedId: targetUserId },
        ],
      },
    });
    if (block) return res.status(403).json({ error: 'Cannot send request' });

    // Check target user privacy
    const targetUser = await prisma.user.findUnique({
      where: { id: targetUserId },
      select: { messagePrivacy: true },
    });
    if (!targetUser) return res.status(404).json({ error: 'User not found' });

    // Check if pending request already exists
    const pendingRequest = await prisma.friendRequest.findFirst({
      where: {
        OR: [
          { senderId: req.userId, receiverId: targetUserId, status: 'PENDING' },
          { senderId: targetUserId, receiverId: req.userId, status: 'PENDING' },
        ],
      },
    });
    if (pendingRequest) {
      return res.status(409).json({ error: 'Friend request already exists' });
    }

    const request = await prisma.friendRequest.create({
      data: {
        senderId: req.userId,
        receiverId: targetUserId,
        status: 'PENDING',
      },
    });

    res.status(201).json({ request });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/friends/request/:requestId/accept
router.post('/request/:requestId/accept', requireAuth, async (req, res) => {
  const { requestId } = req.params;

  try {
    const request = await prisma.friendRequest.findUnique({
      where: { id: requestId },
    });

    if (!request || request.receiverId !== req.userId) {
      return res.status(404).json({ error: 'Request not found' });
    }

    if (request.status !== 'PENDING') {
      return res.status(400).json({ error: 'Request already processed' });
    }

    // Update request status and create friendship atomically
    const [updatedRequest, friendship] = await prisma.$transaction([
      prisma.friendRequest.update({
        where: { id: requestId },
        data: { status: 'ACCEPTED' },
      }),
      prisma.friendship.create({
        data: {
          userAId: request.senderId,
          userBId: request.receiverId,
        },
      }),
    ]);

    res.json({ success: true, friendship });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/friends/request/:requestId/decline
router.post('/request/:requestId/decline', requireAuth, async (req, res) => {
  const { requestId } = req.params;

  try {
    const request = await prisma.friendRequest.findUnique({
      where: { id: requestId },
    });

    if (!request || request.receiverId !== req.userId) {
      return res.status(404).json({ error: 'Request not found' });
    }

    await prisma.friendRequest.update({
      where: { id: requestId },
      data: { status: 'DECLINED' },
    });

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/friends/:userId
router.delete('/:userId', requireAuth, async (req, res) => {
  const { userId } = req.params;

  try {
    await prisma.friendship.deleteMany({
      where: {
        OR: [
          { userAId: req.userId, userBId: userId },
          { userAId: userId, userBId: req.userId },
        ],
      },
    });

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
