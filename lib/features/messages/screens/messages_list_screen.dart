import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../config/constants.dart';
import '../../../core/services/stream_service.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  late final StreamChannelListController _controller;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final currentUserId =
        context.read<AuthProvider>().currentUser?.id ?? '';

    _controller = StreamChannelListController(
      client: StreamService().client,
      filter: Filter.and([
        Filter.in_('members', [currentUserId]),
        Filter.equal('type', 'messaging'),
      ]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 30,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(theme, isDark),
          Expanded(child: _buildChannelList(theme, isDark)),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Messages'),
      actions: [
        IconButton(
          onPressed: () => context.go('/home/settings'),
          icon: const Icon(Icons.settings_outlined, size: 22),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E35)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(LionRadius.full),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelList(ThemeData theme, bool isDark) {
    return PagedValueListenableBuilder<int, Channel>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return value.when(
          (channels, nextPageKey, error) {
            final filtered = _searchQuery.isEmpty
                ? channels
                : channels.where((c) {
                    final name = _getChannelName(c).toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

            if (filtered.isEmpty) {
              return _controller.currentValue?.isLoading == true
                  ? _buildShimmer()
                  : _buildEmpty(theme);
            }

            return RefreshIndicator(
              color: LionColors.primary,
              onRefresh: () => _controller.refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filtered.length +
                    (nextPageKey != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filtered.length) {
                    _controller.loadMore();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: LionColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  return _ChannelTile(
                    channel: filtered[index],
                    index: index,
                  );
                },
              ),
            );
          },
          loading: () => _buildShimmer(),
          error: (e) => _buildError(theme, e.toString()),
        );
      },
    );
  }

  String _getChannelName(Channel channel) {
    final currentUserId =
        StreamService().client.state.currentUser?.id ?? '';
    if (channel.name != null && channel.name!.isNotEmpty) {
      return channel.name!;
    }
    final otherMember = channel.state?.members
        .firstWhere(
          (m) => m.userId != currentUserId,
          orElse: () => channel.state!.members.first,
        );
    return otherMember?.user?.name ?? 'Unknown';
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E35)
                    : const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E35)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E35)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: i * 60)).fadeIn(),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: LionColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: LionColors.primary,
              size: 40,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: theme.textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Add a friend and start messaging',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load messages',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _controller.refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => context.go('/home/search'),
      backgroundColor: LionColors.primary,
      elevation: 4,
      child: const Icon(Icons.edit_rounded, color: Colors.white),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          delay: 300.ms,
        );
  }
}

class _ChannelTile extends StatefulWidget {
  final Channel channel;
  final int index;

  const _ChannelTile({required this.channel, required this.index});

  @override
  State<_ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId =
        StreamService().client.state.currentUser?.id ?? '';

    return StreamBuilder<ChannelState>(
      stream: widget.channel.state!.channelStateStream,
      initialData: widget.channel.state!.channelState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final lastMessage = widget.channel.state?.messages.lastOrNull;
        final unread = widget.channel.state?.unreadCount ?? 0;

        // Resolve the other user's info
        final otherMember = widget.channel.state?.members.firstWhere(
          (m) => m.userId != currentUserId,
          orElse: () => widget.channel.state!.members.first,
        );
        final otherUser = otherMember?.user;
        final name = otherUser?.name ??
            widget.channel.name ??
            'Unknown';
        final avatar = otherUser?.image;
        final isOnline = otherUser?.online ?? false;

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            context.go(
              '/home/chat/${widget.channel.id}',
              extra: {
                'name': name,
                'avatar': avatar,
                'userId': otherUser?.id ?? '',
              },
            );
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: _isPressed
                ? (isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03))
                : Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: avatar,
                  name: name,
                  size: 52,
                  showOnline: true,
                  isOnline: isOnline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: unread > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lastMessage?.createdAt != null)
                            Text(
                              timeago.format(
                                lastMessage!.createdAt,
                                locale: 'en_short',
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: unread > 0
                                    ? LionColors.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                fontWeight: unread > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage?.text ??
                                  'Start a conversation',
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                color: unread > 0
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.85)
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                fontWeight: unread > 0
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: LionColors.primary,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                unread > 99
                                    ? '99+'
                                    : unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate(
              delay: Duration(
                  milliseconds: widget.index * 40),
            )
            .fadeIn(duration: 300.ms)
            .slideX(
                begin: 0.05, end: 0, duration: 300.ms);
      },
    );
  }
}
