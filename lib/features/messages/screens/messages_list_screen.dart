import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../config/constants.dart';
import '../../../core/services/stream_service.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/friends_provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final friends = context.read<FriendsProvider>();
        if (friends.friends.isEmpty && !friends.isLoading) {
          friends.loadFriends();
        }
      }
    });
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
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildSearchBar(theme, isDark),
          Expanded(
            child: _buildBody(theme, isDark),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LionColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Messages'),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Container(
        height: 42,
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
            hintText: 'Search conversations...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.38),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.38),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    return CustomScrollView(
      slivers: [
        // Active Friends section
        SliverToBoxAdapter(
          child: _ActiveFriendsSection(isDark: isDark),
        ),
        // Channel list
        SliverFillRemaining(
          child: _buildChannelList(theme, isDark),
        ),
      ],
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
                  ? _buildShimmer(isDark)
                  : _buildEmpty(theme);
            }

            return RefreshIndicator(
              color: LionColors.primary,
              onRefresh: () => _controller.refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96, top: 4),
                itemCount: filtered.length + (nextPageKey != null ? 1 : 0),
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
          loading: () => _buildShimmer(isDark),
          error: (e) => _buildError(theme),
        );
      },
    );
  }

  String _getChannelName(Channel channel) {
    final currentUserId = StreamService().client.state.currentUser?.id ?? '';
    if (channel.name != null && channel.name!.isNotEmpty) {
      return channel.name!;
    }
    final otherMember = channel.state?.members.firstWhere(
      (m) => m.userId != currentUserId,
      orElse: () => channel.state!.members.first,
    );
    return otherMember?.user?.name ?? 'Unknown';
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E1E35) : const Color(0xFFEBEBF0),
      highlightColor: isDark ? const Color(0xFF2D2D4E) : const Color(0xFFF8F8FC),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
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
                      width: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 10,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: LionColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: LionColors.primary,
              size: 42,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 20),
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
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => context.go('/home/search'),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Find Friends'),
            style: TextButton.styleFrom(
              foregroundColor: LionColors.primary,
              backgroundColor: LionColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LionRadius.full),
              ),
            ),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 52,
            color: theme.colorScheme.onSurface.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
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
      elevation: 6,
      child: const Icon(Icons.edit_rounded, color: Colors.white),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          delay: 400.ms,
        );
  }
}

// ── Active Friends Section ──────────────────────────────────────────────────

class _ActiveFriendsSection extends StatelessWidget {
  final bool isDark;
  const _ActiveFriendsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<FriendsProvider>(
      builder: (context, provider, _) {
        final onlineFriends =
            provider.friends.where((f) => f.isOnline).toList();
        if (onlineFriends.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: LionColors.online,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 900.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 7),
                  Text(
                    'Active Now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: LionColors.online.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${onlineFriends.length}',
                      style: const TextStyle(
                        color: LionColors.online,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: onlineFriends.length,
                itemBuilder: (context, index) => _ActiveFriendBubble(
                  user: onlineFriends[index],
                ).animate(delay: Duration(milliseconds: index * 50)).fadeIn(
                      duration: 250.ms,
                    ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? LionColors.dividerDark : LionColors.dividerLight,
            ),
          ],
        );
      },
    );
  }
}

class _ActiveFriendBubble extends StatefulWidget {
  final AppUser user;
  const _ActiveFriendBubble({required this.user});

  @override
  State<_ActiveFriendBubble> createState() => _ActiveFriendBubbleState();
}

class _ActiveFriendBubbleState extends State<_ActiveFriendBubble> {
  bool _loading = false;

  Future<void> _openChat() async {
    setState(() => _loading = true);
    try {
      final channel =
          await StreamService().getOrCreateDMChannel(widget.user.id);
      if (mounted) {
        context.go(
          '/home/chat/${channel.id}',
          extra: {
            'name': widget.user.displayName,
            'avatar': widget.user.avatarUrl,
            'userId': widget.user.id,
          },
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = widget.user.displayName.split(' ').first;

    return GestureDetector(
      onTap: _loading ? null : _openChat,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: LionColors.online,
                      width: 2.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: LionColors.online,
                          strokeWidth: 2,
                        )
                      : UserAvatar(
                          imageUrl: widget.user.avatarUrl,
                          name: widget.user.displayName,
                          size: 46,
                        ),
                ),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: LionColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 58,
              child: Text(
                firstName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Channel Tile ────────────────────────────────────────────────────────────

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
    final currentUserId = StreamService().client.state.currentUser?.id ?? '';

    return StreamBuilder<ChannelState>(
      stream: widget.channel.state!.channelStateStream,
      initialData: widget.channel.state!.channelState,
      builder: (context, snapshot) {
        final lastMessage = widget.channel.state?.messages.lastOrNull;
        final unread = widget.channel.state?.unreadCount ?? 0;

        final otherMember = widget.channel.state?.members.firstWhere(
          (m) => m.userId != currentUserId,
          orElse: () => widget.channel.state!.members.first,
        );
        final otherUser = otherMember?.user;
        final name = otherUser?.name ?? widget.channel.name ?? 'Unknown';
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
            duration: const Duration(milliseconds: 100),
            color: _isPressed
                ? (isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03))
                : Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                                        .withOpacity(0.38),
                                fontWeight: unread > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage?.text ?? 'Start a conversation',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: unread > 0
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.85)
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.48),
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
                              constraints: const BoxConstraints(minWidth: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    LionColors.primary,
                                    LionColors.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
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
            .animate(delay: Duration(milliseconds: widget.index * 35))
            .fadeIn(duration: 280.ms)
            .slideX(begin: 0.04, end: 0, duration: 280.ms);
      },
    );
  }
}
