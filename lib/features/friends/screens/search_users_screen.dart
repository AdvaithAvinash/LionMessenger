import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/friends_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/user_avatar.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    context.read<FriendsProvider>().clearSearch();
    super.dispose();
  }

  void _search(String q) {
    if (!_hasSearched) setState(() => _hasSearched = true);
    context.read<FriendsProvider>().searchUsers(q);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E35)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(LionRadius.full),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _search,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search by name or username...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _search('');
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, provider, _) {
          if (!_hasSearched) return _buildInitial(theme);
          if (provider.isSearching) return _buildLoading();
          if (provider.searchResults.isEmpty) return _buildNoResults(theme);
          return _buildResults(provider, theme);
        },
      ),
    );
  }

  Widget _buildInitial(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LionColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: LionColors.primary,
              size: 36,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'Find People',
            style: theme.textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Search by display name or @username',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: LionColors.primary),
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: theme.textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Try a different name or username',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildResults(FriendsProvider provider, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) => _SearchUserTile(
        user: provider.searchResults[index],
        index: index,
        onSendRequest: () =>
            provider.sendFriendRequest(provider.searchResults[index].id),
      ),
    );
  }
}

class _SearchUserTile extends StatefulWidget {
  final AppUser user;
  final int index;
  final Future<bool> Function() onSendRequest;

  const _SearchUserTile({
    required this.user,
    required this.index,
    required this.onSendRequest,
  });

  @override
  State<_SearchUserTile> createState() => _SearchUserTileState();
}

class _SearchUserTileState extends State<_SearchUserTile> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: UserAvatar(
        imageUrl: user.avatarUrl,
        name: user.displayName,
        size: 50,
      ),
      title: Text(user.displayName, style: theme.textTheme.titleMedium),
      subtitle: Text(
        '@${user.username}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: _buildTrailing(context, user, theme),
    )
        .animate(delay: Duration(milliseconds: widget.index * 50))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildTrailing(
    BuildContext context,
    AppUser user,
    ThemeData theme,
  ) {
    switch (user.friendStatus) {
      case FriendRequestStatus.accepted:
        return Chip(
          label: const Text('Friends'),
          backgroundColor: LionColors.primary.withOpacity(0.1),
          labelStyle: const TextStyle(
            color: LionColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        );

      case FriendRequestStatus.sent:
        return Chip(
          label: const Text('Sent'),
          backgroundColor: theme.colorScheme.outline.withOpacity(0.1),
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        );

      case FriendRequestStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SmallButton(
              icon: Icons.check_rounded,
              color: LionColors.accentGreen,
              onTap: () {},
            ),
            const SizedBox(width: 6),
            _SmallButton(
              icon: Icons.close_rounded,
              color: LionColors.busy,
              onTap: () {},
            ),
          ],
        );

      default:
        return _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: LionColors.primary,
                  strokeWidth: 2,
                ),
              )
            : GestureDetector(
                onTap: () async {
                  setState(() => _loading = true);
                  await widget.onSendRequest();
                  setState(() => _loading = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LionColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(LionRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: LionColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
    }
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
