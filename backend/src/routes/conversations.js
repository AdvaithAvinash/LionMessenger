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

// GET /api/conversations - List DM channels
router.get('/', requireAuth, async (req, res) => {
  try {
    const filter = {
      type: 'messaging',
      members: { $in: [req.userId] },
    };
    const sort = [{ last_message_at: -1 }];

    const channels = await streamClient.queryChannels(filter, sort, {
      limit: 30,
    });

    const conversations = await Promise.all(
      channels.map(async (channel) => {
        const members = Object.values(channel.state.members || {});
        const otherMember = members.find((m) => m.user_id !== req.userId);

        if (!otherMember) return null;

        const lastMessage = channel.state.messages[channel.state.messages.length - 1];

        return {
          id: channel.id,
          userId: otherMember.user_id,
          userName: otherMember.user?.name || 'Unknown',
          userAvatar: otherMember.user?.image,
          lastMessage: lastMessage?.text,
          lastMessageTime: lastMessage?.created_at,
          unreadCount: channel.countUnread(),
          isOnline: otherMember.user?.online || false,
        };
      })
    );

    res.json({ conversations: conversations.filter(Boolean) });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/conversations/dm - Get or create a DM channel
router.post('/dm', requireAuth, async (req, res) => {
  const { targetUserId } = req.body;

  if (!targetUserId || targetUserId === req.userId) {
    return res.status(400).json({ error: 'Invalid target user' });
  }

  try {
    // Check if blocked
    const block = await prisma.block.findFirst({
      where: {
        OR: [
          { blockerId: req.userId, blockedId: targetUserId },
          { blockerId: targetUserId, blockedId: req.userId },
        ],
      },
    });
    if (block) return res.status(403).json({ error: 'Cannot message this user' });

    // Check target user's privacy settings
    const targetUser = await prisma.user.findUnique({
      where: { id: targetUserId },
    });
    if (!targetUser) return res.status(404).json({ error: 'User not found' });

    if (targetUser.messagePrivacy === 'FRIENDS') {
      const friendship = await prisma.friendship.findFirst({
        where: {
          OR: [
            { userAId: req.userId, userBId: targetUserId },
            { userAId: targetUserId, userBId: req.userId },
          ],
        },
      });
      if (!friendship) {
        return res.status(403).json({
          error: 'This user only accepts messages from friends',
        });
      }
    }

    // Create or get DM channel
    const channelId = [req.userId, targetUserId].sort().join('_');
    const channel = streamClient.channel('messaging', channelId, {
      members: [req.userId, targetUserId],
      created_by_id: req.userId,
    });

    await channel.create();

    res.json({ channelId });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
