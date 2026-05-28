import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../config/constants.dart';
import '../../../core/services/stream_service.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../friends/providers/friends_provider.dart';

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

class _ChatScreenState extends State<ChatScreen> {
  Channel? _channel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  Future<void> _initChannel() async {
    try {
      final client = StreamService().client;
      final channel = client.channel('messaging', id: widget.channelId);
      await channel.watch();
      if (mounted) {
        setState(() {
          _channel = channel;
          _isLoading = false;
        });
        await channel.markRead();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: _buildBackButton(context),
          title: _buildTitleLoading(theme),
          titleSpacing: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: LionColors.primary),
        ),
      );
    }

    if (_error != null || _channel == null) {
      return Scaffold(
        appBar: AppBar(
          leading: _buildBackButton(context),
          title: Text(widget.userName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: LionColors.busy.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: LionColors.busy, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Could not load chat'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initChannel();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return StreamChannel(
      channel: _channel!,
      child: Scaffold(
        backgroundColor: isDark
            ? LionColors.backgroundDark
            : const Color(0xFFF0F0F8),
        appBar: _buildAppBar(context, theme),
        body: Stack(
          children: [
            // Subtle dot-grid background
            SizedBox.expand(
              child: CustomPaint(
                painter: _ChatBgPainter(
                  dotColor: isDark
                      ? Colors.white.withOpacity(0.025)
                      : Colors.black.withOpacity(0.025),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: StreamMessageListView(
                    threadBuilder: (_, parentMessage) =>
                        ThreadPage(parent: parentMessage!),
                    messageFilter: defaultFilter,
                  ),
                ),
                StreamMessageInput(
                  preMessageSending: (message) async => message,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      leadingWidth: 48,
      leading: _buildBackButton(context),
      titleSpacing: 0,
      title: _buildTitle(context, theme),
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

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: widget.userId.isNotEmpty
          ? () => context.go('/home/profile/${widget.userId}')
          : null,
      child: Row(
        children: [
          Hero(
            tag: 'chat_avatar_${widget.userId}',
            child: UserAvatar(
              imageUrl: widget.userAvatar,
              name: widget.userName,
              size: 38,
              showOnline: _channel != null,
              isOnline: _channel?.state?.members
                      .firstWhere(
                        (m) => m.userId == widget.userId,
                        orElse: () => Member(),
                      )
                      .user
                      ?.online ??
                  false,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_channel != null)
                  StreamBuilder<List<Member>>(
                    stream: _channel!.state!.membersStream,
                    initialData: _channel!.state!.members,
                    builder: (context, snapshot) {
                      final isOnline = snapshot.data
                              ?.firstWhere(
                                (m) => m.userId == widget.userId,
                                orElse: () => Member(),
                              )
                              .user
                              ?.online ??
                          false;
                      return Row(
                        children: [
                          if (isOnline)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: const BoxDecoration(
                                color: LionColors.online,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            isOnline ? 'Active now' : 'Offline',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOnline
                                  ? LionColors.online
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleLoading(ThemeData theme) {
    return Row(
      children: [
        UserAvatar(
          imageUrl: widget.userAvatar,
          name: widget.userName,
          size: 38,
        ),
        const SizedBox(width: 10),
        Text(widget.userName, style: theme.textTheme.titleMedium),
      ],
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ChatOptionsSheet(
        userName: widget.userName,
        userId: widget.userId,
        channel: _channel,
      ),
    );
  }
}

class _ChatBgPainter extends CustomPainter {
  final Color dotColor;
  const _ChatBgPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    const spacing = 22.0;
    const radius = 1.4;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ThreadPage extends StatelessWidget {
  final Message parent;
  const ThreadPage({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(parentMessage: parent),
          ),
          StreamMessageInput(parentMessage: parent),
        ],
      ),
    );
  }
}

class _ChatOptionsSheet extends StatelessWidget {
  final String userName;
  final String userId;
  final Channel? channel;

  const _ChatOptionsSheet({
    required this.userName,
    required this.userId,
    this.channel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  userName,
                  style: theme.textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Chat settings',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.person_outlined,
            label: 'View Profile',
            onTap: () {
              Navigator.pop(context);
              if (userId.isNotEmpty) {
                context.go('/home/profile/$userId');
              }
            },
          ),
          _OptionTile(
            icon: Icons.notifications_off_outlined,
            label: 'Mute Notifications',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Icons.search_rounded,
            label: 'Search Messages',
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 20),
          if (channel != null)
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Conversation',
              color: LionColors.busy,
              onTap: () async {
                Navigator.pop(context);
                await channel!.delete();
                if (context.mounted) context.go('/home');
              },
            ),
          _OptionTile(
            icon: Icons.block_rounded,
            label: 'Block ${userName.split(' ').first}',
            color: LionColors.busy,
            onTap: () async {
              Navigator.pop(context);
              if (userId.isNotEmpty && context.mounted) {
                final friends = context.read<FriendsProvider>();
                // Block via API
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Blocked $userName'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
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
    final isDark = theme.brightness == Brightness.dark;
    final c = color ?? theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LionRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.withOpacity(isDark ? 0.1 : 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: c, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: c,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
