import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../config/constants.dart';
import '../../../core/services/stream_service.dart';
import '../../../shared/widgets/user_avatar.dart';

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
        // Mark channel as read when opened
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
          title: _buildAppBarTitle(context),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: LionColors.primary),
        ),
      );
    }

    if (_error != null || _channel == null) {
      return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
          title: Text(widget.userName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: LionColors.busy,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text('Could not load chat'),
              const SizedBox(height: 8),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(
                threadBuilder: (_, parentMessage) =>
                    ThreadPage(parent: parentMessage!),
                onMessageSwiped: (message) {
                  // Swipe to reply handled by Stream's default
                },
              ),
            ),
            StreamMessageInput(
              preMessageSending: (message) async {
                // Pre-process message if needed
                return message;
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: 48,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.arrow_back_rounded),
        ),
      ),
      title: _buildAppBarTitle(context),
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

  Widget _buildAppBarTitle(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.userId.isNotEmpty
          ? () => context.go('/home/profile/${widget.userId}')
          : null,
      child: Row(
        children: [
          UserAvatar(
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
                      return Text(
                        isOnline ? 'Active now' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOnline
                              ? LionColors.online
                              : theme.colorScheme.onSurface
                                  .withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
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

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ChatOptionsSheet(
        userName: widget.userName,
        channel: _channel,
      ),
    );
  }
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
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_back_rounded),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(
              parentMessage: parent,
            ),
          ),
          StreamMessageInput(parentMessage: parent),
        ],
      ),
    );
  }
}

class _ChatOptionsSheet extends StatelessWidget {
  final String userName;
  final Channel? channel;

  const _ChatOptionsSheet({required this.userName, this.channel});

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
          Text(userName, style: theme.textTheme.headlineSmall),
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
            label: 'Block User',
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
