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
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (user != null)
            _buildProfileHeader(context, theme, isDark, user),
          const SizedBox(height: 20),
          _buildSection(
            'Preferences',
            [
              _SettingsTile(
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                iconColor: const Color(0xFFFBBC04),
                label: 'Dark Mode',
                trailing: Switch.adaptive(
                  value: appProvider.isDark,
                  onChanged: (_) => appProvider.toggleTheme(),
                  activeColor: LionColors.primary,
                ),
              ),
            ],
            theme,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildSection(
            'Privacy & Safety',
            [
              _SettingsTile(
                icon: Icons.security_outlined,
                iconColor: LionColors.primary,
                label: 'Privacy Settings',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.35),
                ),
                onTap: () => context.go('/home/settings/privacy'),
              ),
              _SettingsTile(
                icon: Icons.block_rounded,
                iconColor: LionColors.busy,
                label: 'Blocked Users',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.35),
                ),
                onTap: () => context.go('/home/settings/blocked'),
              ),
            ],
            theme,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildSection(
            'Notifications',
            [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: LionColors.accent,
                label: 'Message Notifications',
                trailing: Switch.adaptive(
                  value: true,
                  onChanged: (_) {},
                  activeColor: LionColors.primary,
                ),
              ),
              _SettingsTile(
                icon: Icons.mark_chat_read_outlined,
                iconColor: LionColors.accentGreen,
                label: 'Friend Request Alerts',
                trailing: Switch.adaptive(
                  value: true,
                  onChanged: (_) {},
                  activeColor: LionColors.primary,
                ),
              ),
            ],
            theme,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildSection(
            'Account',
            [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: theme.colorScheme.onSurface.withOpacity(0.5),
                label: 'About LionMessenger',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.35),
                ),
                onTap: () => _showAbout(context),
              ),
              _SettingsTile(
                icon: Icons.logout_rounded,
                iconColor: LionColors.busy,
                label: 'Sign Out',
                labelColor: LionColors.busy,
                onTap: () => _confirmSignOut(context, auth),
              ),
            ],
            theme,
            isDark,
          ),
          const SizedBox(height: 40),
          // Footer
          Center(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LionColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: LionColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'LionMessenger v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ♥ for privacy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    UserProfile user,
  ) {
    return GestureDetector(
      onTap: () => context.go('/home/profile/${user.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LionColors.primaryGradient,
          borderRadius: BorderRadius.circular(LionRadius.xl),
          boxShadow: [
            BoxShadow(
              color: LionColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2.5,
                ),
              ),
              child: UserAvatar(
                imageUrl: user.avatarUrl,
                name: user.displayName,
                size: 56,
              ),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.38),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
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

  void _showAbout(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.xl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LionColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LionMessenger',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A modern messaging app that respects your privacy. No phone number required — ever.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.xl),
        ),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You can always sign back in with your email.',
        ),
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
  final Color? iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.label,
    this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveLabelColor = labelColor ?? theme.colorScheme.onSurface;
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.onSurface.withOpacity(0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LionRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(isDark ? 0.12 : 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: effectiveLabelColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
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
