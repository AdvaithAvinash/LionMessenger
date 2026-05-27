import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/user_avatar.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: const Text('Blocked Users'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (settings.blockedUsers.isEmpty) {
            return _buildEmpty(theme);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: settings.blockedUsers.length,
            itemBuilder: (context, index) => _BlockedUserTile(
              user: settings.blockedUsers[index],
              index: index,
              onUnblock: () async {
                final confirmed = await _confirmUnblock(
                  context,
                  settings.blockedUsers[index],
                );
                if (confirmed == true) {
                  await settings.unblockUser(
                    settings.blockedUsers[index].id,
                  );
                }
              },
            ),
          );
        },
      ),
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
              Icons.block_rounded,
              color: LionColors.primary,
              size: 40,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'No blocked users',
            style: theme.textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Users you block will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Future<bool?> _confirmUnblock(BuildContext context, BlockedUser user) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text(
          'Unblock ${user.displayName}? They will be able to send you friend requests again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: LionColors.primary,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  final BlockedUser user;
  final int index;
  final VoidCallback onUnblock;

  const _BlockedUserTile({
    required this.user,
    required this.index,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      trailing: GestureDetector(
        onTap: onUnblock,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withOpacity(0.1),
            borderRadius: BorderRadius.circular(LionRadius.sm),
          ),
          child: Text(
            'Unblock',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: LionColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }
}
