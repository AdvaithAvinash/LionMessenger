import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });
}

class ChatScreen extends StatefulWidget {
  final String channelId;
  final String userName;
  final String? userAvatar;
  final String userId;

  const ChatScreen({
    super.key,
    required this.channelId,
    required this.userName,
    this.userAvatar,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _showAttachments = false;

  // Demo messages for UI preview
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() => _isTyping = _messageController.text.isNotEmpty);
    });
    _loadDemoMessages();
  }

  void _loadDemoMessages() {
    final currentUserId =
        context.read<AuthProvider>().currentUser?.id ?? 'me';
    // These are placeholder messages — in production, Stream Chat SDK drives this
    setState(() {
      _messages.addAll([
        ChatMessage(
          id: '1',
          senderId: widget.userId,
          text: 'Hey! How are you doing? 👋',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: '2',
          senderId: currentUserId,
          text: 'I\'m doing great, thanks for asking!',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
          isRead: true,
        ),
        ChatMessage(
          id: '3',
          senderId: widget.userId,
          text: 'That\'s awesome! Have you tried LionMessenger yet?',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        ),
        ChatMessage(
          id: '4',
          senderId: currentUserId,
          text: 'Yes, I\'m using it right now! The UI looks amazing 🦁',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isRead: true,
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId =
        context.read<AuthProvider>().currentUser?.id ?? 'me';

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        text: text,
        createdAt: DateTime.now(),
        isRead: false,
      ));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId =
        context.read<AuthProvider>().currentUser?.id ?? 'me';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: _buildMessageList(theme, isDark, currentUserId),
            ),
          ),
          _buildInputArea(theme, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      leadingWidth: 48,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.arrow_back_rounded),
        ),
      ),
      title: GestureDetector(
        onTap: () =>
            context.go('/home/profile/${widget.userId}'),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: widget.userAvatar,
              name: widget.userName,
              size: 38,
              showOnline: true,
              isOnline: true,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'Active now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: LionColors.online,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.call_outlined, size: 22),
          tooltip: 'Voice call',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.videocam_outlined, size: 22),
          tooltip: 'Video call',
        ),
        IconButton(
          onPressed: () => _showChatOptions(context),
          icon: const Icon(Icons.more_vert_rounded, size: 22),
        ),
      ],
    );
  }

  Widget _buildMessageList(
    ThemeData theme,
    bool isDark,
    String currentUserId,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderId == currentUserId;
        final showDate = index == 0 ||
            _messages[index].createdAt.day !=
                _messages[index - 1].createdAt.day;
        final showAvatar = !isMe &&
            (index == _messages.length - 1 ||
                _messages[index + 1].senderId != msg.senderId);

        return Column(
          children: [
            if (showDate) _buildDateDivider(msg.createdAt, theme, isDark),
            _MessageBubble(
              message: msg,
              isMe: isMe,
              showAvatar: showAvatar,
              userName: widget.userName,
              userAvatar: widget.userAvatar,
              index: index,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date, ThemeData theme, bool isDark) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMMM d').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? LionColors.surfaceDark : LionColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? LionColors.borderDark : LionColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showAttachments = !_showAttachments),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E35)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.35),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: _isTyping
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: const BoxDecoration(
                        gradient: LionColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey('emoji'),
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => _ChatOptionsSheet(userName: widget.userName),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String userName;
  final String? userAvatar;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.userName,
    this.userAvatar,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? UserAvatar(
                    imageUrl: userAvatar,
                    name: userName,
                    size: 32,
                  )
                : const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe ? LionColors.primaryGradient : null,
                    color: isMe
                        ? null
                        : isDark
                            ? LionColors.theirBubbleDark
                            : LionColors.theirBubbleLight,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isMe
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.35),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.isRead
                            ? LionColors.primary
                            : theme.colorScheme.onSurface.withOpacity(0.35),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: (index * 30).clamp(0, 300)))
        .fadeIn(duration: 200.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ChatOptionsSheet extends StatelessWidget {
  final String userName;
  const _ChatOptionsSheet({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userName,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.person_outlined,
            label: 'View Profile',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Icons.notifications_off_outlined,
            label: 'Mute Notifications',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Icons.block_rounded,
            label: 'Block User',
            color: LionColors.busy,
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Conversation',
            color: LionColors.busy,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(color: c),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LionRadius.sm),
      ),
    );
  }
}
