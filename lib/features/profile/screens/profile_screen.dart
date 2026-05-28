import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/friends_provider.dart';
import '../../../config/constants.dart';
import '../../../core/services/stream_service.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get _isSelf {
    final auth = context.read<AuthProvider>();
    return auth.currentUser?.id == widget.userId || widget.userId.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, isDark, user),
          SliverToBoxAdapter(
            child: _buildProfileBody(theme, isDark, user),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, bool isDark, UserProfile user) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      leading: _isSelf
          ? null
          : GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
      actions: [
        if (_isSelf)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => context.go('/home/settings'),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (!_isSelf)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showBlockOptions(context),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildProfileHeader(user),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          ...List.generate(6, (i) {
            final sizes = [120.0, 90.0, 70.0, 50.0, 180.0, 60.0];
            final tops = [-30.0, 20.0, 60.0, -20.0, 100.0, 130.0];
            final rights = [-20.0, 180.0, 250.0, 300.0, -40.0, 200.0];
            return Positioned(
              top: tops[i],
              right: rights[i],
              child: Container(
                width: sizes[i],
                height: sizes[i],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04 + i * 0.01),
                ),
              ),
            );
          }),
          // Avatar + name
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Hero(
                  tag: 'profile_avatar_${user.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      imageUrl: user.avatarUrl,
                      name: user.displayName,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBody(ThemeData theme, bool isDark, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons
          if (_isSelf) _buildSelfActions(theme) else _buildOtherActions(theme),
          const SizedBox(height: 24),

          // Stats row
          _buildStatsRow(theme, isDark),
          const SizedBox(height: 24),

          // Bio section
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            _buildSectionTitle('About', theme),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? LionColors.cardDark : LionColors.cardLight,
                borderRadius: BorderRadius.circular(LionRadius.lg),
                border: Border.all(
                  color: isDark ? LionColors.borderDark : LionColors.borderLight,
                ),
              ),
              child: Text(
                user.bio!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Email (only self sees email)
          if (_isSelf) ...[
            _buildSectionTitle('Email', theme),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? LionColors.cardDark : LionColors.cardLight,
                borderRadius: BorderRadius.circular(LionRadius.lg),
                border: Border.all(
                  color: isDark ? LionColors.borderDark : LionColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Privacy setting
          if (_isSelf) ...[
            _buildSectionTitle('Message Privacy', theme),
            const SizedBox(height: 10),
            _buildPrivacyBadge(user.messagePrivacy, theme, isDark),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, bool isDark) {
    return Consumer<FriendsProvider>(
      builder: (context, friends, _) {
        final friendCount = friends.friends.length;
        final onlineCount =
            friends.friends.where((f) => f.isOnline).length;

        return Row(
          children: [
            _StatCard(
              label: 'Friends',
              value: '$friendCount',
              icon: Icons.people_rounded,
              color: LionColors.primary,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Online',
              value: '$onlineCount',
              icon: Icons.circle,
              color: LionColors.online,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Privacy',
              value: _isSelf
                  ? context
                      .read<AuthProvider>()
                      .currentUser
                      ?.messagePrivacy
                      .toLowerCase()
                      .replaceAll('_', ' ') ??
                      'friends'
                  : '—',
              icon: Icons.shield_rounded,
              color: LionColors.accentGreen,
              isDark: isDark,
            ),
          ],
        );
      },
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildPrivacyBadge(
      String privacy, ThemeData theme, bool isDark) {
    final icons = {
      'EVERYONE': Icons.public_rounded,
      'FRIENDS': Icons.people_rounded,
      'NOBODY': Icons.lock_rounded,
    };
    final labels = {
      'EVERYONE': 'Anyone can message you',
      'FRIENDS': 'Only friends can message you',
      'NOBODY': 'No one can message you',
    };
    final colors = {
      'EVERYONE': LionColors.primary,
      'FRIENDS': LionColors.accentGreen,
      'NOBODY': LionColors.busy,
    };

    final icon = icons[privacy] ?? Icons.people_rounded;
    final label = labels[privacy] ?? 'Friends only';
    final color = colors[privacy] ?? LionColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(LionRadius.lg),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/home/settings/privacy'),
            child: Text(
              'Change',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfActions(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showEditProfile(context),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LionColors.primaryGradient,
                borderRadius: BorderRadius.circular(LionRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: LionColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(LionRadius.md),
          ),
          child: const Icon(Icons.share_outlined, size: 18),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildOtherActions(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<FriendsProvider>(
      builder: (context, provider, _) {
        final isFriend = provider.friends.any((f) => f.id == widget.userId);

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isFriend ? () => _openDM(context) : () => _sendRequest(context, provider),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LionColors.primaryGradient,
                    borderRadius: BorderRadius.circular(LionRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: LionColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFriend
                            ? Icons.chat_bubble_outline_rounded
                            : Icons.person_add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFriend ? 'Message' : 'Add Friend',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(LionRadius.md),
              ),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDM(BuildContext context) async {
    try {
      final channel = await StreamService().getOrCreateDMChannel(widget.userId);
      if (context.mounted) {
        final user = context.read<AuthProvider>().currentUser;
        context.go(
          '/home/chat/${channel.id}',
          extra: {
            'name': user?.displayName ?? 'User',
            'avatar': user?.avatarUrl,
            'userId': widget.userId,
          },
        );
      }
    } catch (_) {}
  }

  Future<void> _sendRequest(BuildContext context, FriendsProvider provider) async {
    await provider.sendFriendRequest(widget.userId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.4),
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        fontSize: 11,
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditProfileSheet(),
    );
  }

  void _showBlockOptions(BuildContext context) {
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
                'Block User',
                style: TextStyle(color: LionColors.busy),
              ),
              onTap: () => Navigator.pop(context),
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
                  Icons.flag_outlined,
                  color: LionColors.busy,
                  size: 20,
                ),
              ),
              title: const Text(
                'Report User',
                style: TextStyle(color: LionColors.busy),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? LionColors.cardDark : LionColors.cardLight,
          borderRadius: BorderRadius.circular(LionRadius.lg),
          border: Border.all(
            color: isDark ? LionColors.borderDark : LionColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _displayNameCtrl;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _displayNameCtrl = TextEditingController(text: user?.displayName ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Edit Profile', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            'DISPLAY NAME',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _displayNameCtrl,
            decoration: const InputDecoration(hintText: 'Your display name'),
          ),
          const SizedBox(height: 20),
          Text(
            'BIO',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tell people about yourself...',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) => ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await auth.updateProfile(
                          displayName: _displayNameCtrl.text.trim(),
                          bio: _bioCtrl.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
