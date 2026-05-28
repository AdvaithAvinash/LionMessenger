import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/friends_provider.dart';
import '../../../config/constants.dart';
import '../../../core/services/stream_service.dart';
import '../../../shared/widgets/user_avatar.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FriendsProvider>();
      provider.loadFriends();
      provider.loadIncomingRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: LionColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: LionColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Friends'),
          ],
        ),
        actions: [
          Consumer<FriendsProvider>(
            builder: (context, p, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => context.go('/home/friend-requests'),
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  tooltip: 'Friend requests',
                ),
                if (p.pendingRequestCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: LionColors.busy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.pendingRequestCount > 9
                              ? '9+'
                              : p.pendingRequestCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                        ),
                  ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(LionRadius.full),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withOpacity(0.5),
              indicator: BoxDecoration(
                gradient: LionColors.primaryGradient,
                borderRadius: BorderRadius.circular(LionRadius.full),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'All Friends'),
                Tab(text: 'Online'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, provider, _) => TabBarView(
          controller: _tabController,
          children: [
            _buildFriendsList(provider.friends, provider, all: true),
            _buildFriendsList(
              provider.friends.where((f) => f.isOnline).toList(),
              provider,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home/search'),
        backgroundColor: LionColors.primary,
        elevation: 6,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Add Friend',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ).animate().scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
            delay: 300.ms,
          ),
    );
  }

  Widget _buildFriendsList(
    List<AppUser> friends,
    FriendsProvider provider, {
    bool all = false,
  }) {
    if (provider.isLoading && friends.isEmpty) {
      return _buildShimmer();
    }

    if (friends.isEmpty) {
      return _buildEmpty(all);
    }

    return RefreshIndicator(
      color: LionColors.primary,
      onRefresh: () => provider.loadFriends(),
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: friends.length,
          itemBuilder: (context, index) => _FriendTile(
            user: friends[index],
            index: index,
            onRemove: () async {
              final confirmed = await _confirmRemove(context, friends[index]);
              if (confirmed == true) {
                await provider.removeFriend(friends[index].id);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context, AppUser user) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.lg),
        ),
        title: const Text('Remove Friend'),
        content: Text(
          'Remove ${user.displayName} from your friends? You can always re-add them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: LionColors.busy),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool all) {
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
            child: Icon(
              all ? Icons.people_outline_rounded : Icons.circle_outlined,
              color: LionColors.primary,
              size: 42,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            all ? 'No friends yet' : 'No one is online',
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            all
                ? 'Search for people and send\nfriend requests to connect'
                : 'Your online friends will appear here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E1E35) : const Color(0xFFEBEBF0),
      highlightColor:
          isDark ? const Color(0xFF2D2D4E) : const Color(0xFFF8F8FC),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (_, i) => Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final AppUser user;
  final int index;
  final VoidCallback onRemove;

  const _FriendTile({
    required this.user,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: Key(user.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => _showBlockConfirm(context),
            backgroundColor: LionColors.away,
            foregroundColor: Colors.white,
            icon: Icons.block_rounded,
            label: 'Block',
          ),
          SlidableAction(
            onPressed: (_) => onRemove(),
            backgroundColor: LionColors.busy,
            foregroundColor: Colors.white,
            icon: Icons.person_remove_rounded,
            label: 'Remove',
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Stack(
          children: [
            UserAvatar(
              imageUrl: user.avatarUrl,
              name: user.displayName,
              size: 52,
            ),
            if (user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isOnline)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: LionColors.online.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Online',
                  style: TextStyle(
                    color: LionColors.online,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '@${user.username}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageButton(user: user),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.more_vert_rounded,
              onTap: () => _showOptions(context),
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 45))
        .fadeIn(duration: 280.ms)
        .slideX(begin: 0.04, end: 0, duration: 280.ms);
  }

  void _showBlockConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.lg),
        ),
        title: const Text('Block User'),
        content: Text(
          'Block ${user.displayName}? They will no longer be able to message you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: LionColors.busy),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
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
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/profile/${user.id}');
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LionColors.busy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.block_rounded,
                  color: LionColors.busy,
                  size: 20,
                ),
              ),
              title: const Text(
                'Block',
                style: TextStyle(color: LionColors.busy),
              ),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirm(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LionColors.busy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_remove_outlined,
                  color: LionColors.busy,
                  size: 20,
                ),
              ),
              title: const Text(
                'Remove Friend',
                style: TextStyle(color: LionColors.busy),
              ),
              onTap: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, color: widget.color, size: 18),
        ),
      ),
    );
  }
}

class _MessageButton extends StatefulWidget {
  final AppUser user;
  const _MessageButton({required this.user});

  @override
  State<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<_MessageButton> {
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
    return GestureDetector(
      onTap: _loading ? null : _openChat,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: LionColors.primary.withOpacity(_loading ? 0.06 : 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(9),
                child: CircularProgressIndicator(
                  color: LionColors.primary,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.chat_bubble_outline_rounded,
                color: LionColors.primary,
                size: 18,
              ),
      ),
    );
  }
}
