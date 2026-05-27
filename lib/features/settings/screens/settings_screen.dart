import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/user_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final appProvider = context.watch<AppProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildProfileHeader(context, theme, isDark, user),
          const SizedBox(height: 16),
          _buildSection('Preferences', [
            _SettingsTile(
              icon: isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              label: 'Dark Mode',
              trailing: Switch.adaptive(
                value: appProvider.isDark,
                onChanged: (_) => appProvider.toggleTheme(),
                activeColor: LionColors.primary,
              ),
            ),
          ], theme, isDark),
          const SizedBox(height: 8),
          _buildSection('Privacy & Safety', [
            _SettingsTile(
              icon: Icons.security_outlined,
              label: 'Privacy Settings',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
              ),
              onTap: () => context.go('/home/settings/privacy'),
            ),
            _SettingsTile(
              icon: Icons.block_rounded,
              label: 'Blocked Users',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
              ),
              onTap: () => context.go('/home/settings/blocked'),
            ),
          ], theme, isDark),
          const SizedBox(height: 8),
          _buildSection('Notifications', [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Message Notifications',
              trailing: Switch.adaptive(
                value: true,
                onChanged: (_) {},
                activeColor: LionColors.primary,
              ),
            ),
            _SettingsTile(
              icon: Icons.mark_chat_read_outlined,
              label: 'Friend Request Alerts',
              trailing: Switch.adaptive(
                value: true,
                onChanged: (_) {},
                activeColor: LionColors.primary,
              ),
            ),
          ], theme, isDark),
          const SizedBox(height: 8),
          _buildSection('Account', [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'About LionMessenger',
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              labelColor: LionColors.busy,
              iconColor: LionColors.busy,
              onTap: () => _confirmSignOut(context, auth),
            ),
          ], theme, isDark),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  color: LionColors.primary,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  'LionMessenger v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    UserProfile? user,
  ) {
    if (user == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.go('/home/profile/${user.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LionColors.primaryGradient,
          borderRadius: BorderRadius.circular(LionRadius.lg),
          boxShadow: [
            BoxShadow(
              color: LionColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: user.avatarUrl,
              name: user.displayName,
              size: 56,
              borderColor: Colors.white,
              borderWidth: 2,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white70,
              size: 22,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> tiles,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? LionColors.cardDark : LionColors.cardLight,
            borderRadius: BorderRadius.circular(LionRadius.lg),
            border: Border.all(
              color: isDark ? LionColors.borderDark : LionColors.borderLight,
            ),
          ),
          child: Column(
            children: tiles,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: LionColors.busy),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await auth.signOut();
      context.go('/onboarding');
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.labelColor,
    this.iconColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveLabelColor = labelColor ?? theme.colorScheme.onSurface;
    final effectiveIconColor = iconColor ??
        theme.colorScheme.onSurface.withOpacity(0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LionRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(LionRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: effectiveLabelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
