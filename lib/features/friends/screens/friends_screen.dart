import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/friends_provider.dart';
import '../../../config/constants.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
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
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: LionColors.busy,
                        shape: BoxShape.circle,
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
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: LionColors.primary,
          unselectedLabelColor:
              theme.colorScheme.onSurface.withOpacity(0.5),
          indicatorColor: LionColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'All Friends'),
            Tab(text: 'Online'),
          ],
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
    );
  }

  Future<bool?> _confirmRemove(BuildContext context, AppUser user) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Remove ${user.displayName} from your friends?'),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: LionColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              all
                  ? Icons.people_outline_rounded
                  : Icons.circle_outlined,
              color: LionColors.primary,
              size: 40,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
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
                    width: 120,
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
                    width: 80,
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(
        imageUrl: user.avatarUrl,
        name: user.displayName,
        size: 52,
        showOnline: true,
        isOnline: user.isOnline,
      ),
      title: Text(
        user.displayName,
        style: theme.textTheme.titleMedium,
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
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => context.go(
              '/home/chat/${user.id}',
              extra: {
                'name': user.displayName,
                'avatar': user.avatarUrl,
                'userId': user.id,
              },
            ),
            color: LionColors.primary,
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.more_vert_rounded,
            onTap: () => _showOptions(context),
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/profile/${user.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: LionColors.busy),
              title: const Text('Block', style: TextStyle(color: LionColors.busy)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined,
                  color: LionColors.busy),
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
      onTapDown: (_) => setState(() => _scale = 0.9),
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
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(LionRadius.sm),
          ),
          child: Icon(widget.icon, color: widget.color, size: 18),
        ),
      ),
    );
  }
}
