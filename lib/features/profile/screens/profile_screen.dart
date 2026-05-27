import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/friends_provider.dart';
import '../../../config/constants.dart';
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
    return auth.currentUser?.id == widget.userId ||
        widget.userId.isEmpty;
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

  Widget _buildSliverAppBar(
    ThemeData theme,
    bool isDark,
    UserProfile user,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      leading: _isSelf
          ? null
          : GestureDetector(
              onTap: () => context.pop(),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.arrow_back_rounded),
              ),
            ),
      actions: [
        if (_isSelf)
          IconButton(
            onPressed: () => context.go('/home/settings'),
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
        if (!_isSelf) ...[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 22),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              ...List.generate(
                5,
                (i) => Positioned(
                  top: -20.0 + i * 50,
                  right: -20.0 + i * 40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                child: Row(
                  children: [
                    Hero(
                      tag: 'avatar_${user.id}',
                      child: UserAvatar(
                        imageUrl: user.avatarUrl,
                        name: user.displayName,
                        size: 80,
                        borderColor: Colors.white,
                        borderWidth: 3,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBody(
    ThemeData theme,
    bool isDark,
    UserProfile user,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSelf) _buildSelfActions(theme),
          if (!_isSelf) _buildOtherActions(theme),
          const SizedBox(height: 24),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            _buildSection('About', theme),
            const SizedBox(height: 8),
            Text(
              user.bio!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildSection('Member since', theme),
          const SizedBox(height: 8),
          Text(
            'May 2024',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSelfActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () => _showEditProfile(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.share_outlined,
            label: 'Share Profile',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildOtherActions(ThemeData theme) {
    return Consumer<FriendsProvider>(
      builder: (context, provider, _) => Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  gradient: LionColors.primaryGradient,
                  borderRadius: BorderRadius.circular(LionRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: LionColors.primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Add Friend',
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProfileActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Message',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          _ProfileActionButton(
            icon: Icons.more_horiz_rounded,
            label: '',
            onTap: () => _showBlockOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, ThemeData theme) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProfileSheet(),
    );
  }

  void _showBlockOptions(BuildContext context) {
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
            ListTile(
              leading: const Icon(Icons.block_rounded, color: LionColors.busy),
              title: const Text(
                'Block User',
                style: TextStyle(color: LionColors.busy),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: LionColors.busy),
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

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: label.isEmpty
            ? const EdgeInsets.symmetric(horizontal: 14)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(LionRadius.md),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
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
              width: 40,
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
          TextField(
            controller: _displayNameCtrl,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell people about yourself...',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
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
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
