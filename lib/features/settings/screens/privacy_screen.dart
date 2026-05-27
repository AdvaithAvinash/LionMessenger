import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../../../config/constants.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
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
        title: const Text('Privacy Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoBanner(theme, isDark),
            const SizedBox(height: 20),
            _buildPrivacySection(settings, theme, isDark),
            const SizedBox(height: 20),
            _buildReadReceiptsSection(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LionColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(LionRadius.md),
        border: Border.all(
          color: LionColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: LionColors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Control who can message you and interact with your profile.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: LionColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPrivacySection(
    SettingsProvider settings,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHO CAN MESSAGE YOU',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        _PrivacyOption(
          icon: Icons.people_rounded,
          title: 'Friends Only',
          subtitle: 'Only your friends can send you messages',
          isSelected: settings.messagePrivacy == MessagePrivacy.friends,
          isDark: isDark,
          onTap: () =>
              settings.updateMessagePrivacy(MessagePrivacy.friends),
        ),
        const SizedBox(height: 10),
        _PrivacyOption(
          icon: Icons.public_rounded,
          title: 'Everyone',
          subtitle: 'Anyone on LionMessenger can message you',
          isSelected: settings.messagePrivacy == MessagePrivacy.everyone,
          isDark: isDark,
          onTap: () =>
              settings.updateMessagePrivacy(MessagePrivacy.everyone),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildReadReceiptsSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MESSAGE ACTIVITY',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? LionColors.cardDark : LionColors.cardLight,
            borderRadius: BorderRadius.circular(LionRadius.md),
            border: Border.all(
              color: isDark ? LionColors.borderDark : LionColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              _SwitchTile(
                title: 'Read Receipts',
                subtitle: 'Show when you\'ve read messages',
                value: true,
                onChanged: (_) {},
              ),
              Divider(
                color: isDark
                    ? LionColors.dividerDark
                    : LionColors.dividerLight,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _SwitchTile(
                title: 'Typing Indicators',
                subtitle: 'Show when you\'re typing',
                value: true,
                onChanged: (_) {},
              ),
              Divider(
                color: isDark
                    ? LionColors.dividerDark
                    : LionColors.dividerLight,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _SwitchTile(
                title: 'Online Status',
                subtitle: 'Show when you\'re active',
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _PrivacyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? LionColors.primary.withOpacity(0.1)
              : (isDark ? LionColors.cardDark : LionColors.cardLight),
          borderRadius: BorderRadius.circular(LionRadius.md),
          border: Border.all(
            color: isSelected
                ? LionColors.primary.withOpacity(0.5)
                : (isDark ? LionColors.borderDark : LionColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? LionColors.primary.withOpacity(0.15)
                    : theme.colorScheme.onSurface.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? LionColors.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? LionColors.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? LionColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? LionColors.primary
                      : theme.colorScheme.outline.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: LionColors.primary,
          ),
        ],
      ),
    );
  }
}
