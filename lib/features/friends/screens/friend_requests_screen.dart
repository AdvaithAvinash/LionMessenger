import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/friends_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/user_avatar.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().loadIncomingRequests();
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
        title: const Text('Friend Requests'),
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, provider, _) {
          if (provider.incomingRequests.isEmpty) {
            return _buildEmpty(theme);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: provider.incomingRequests.length,
            itemBuilder: (context, index) {
              final request = provider.incomingRequests[index];
              return _RequestCard(
                request: request,
                index: index,
                onAccept: () => provider.acceptRequest(request.id),
                onDecline: () => provider.declineRequest(request.id),
              );
            },
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
              Icons.notifications_none_rounded,
              color: LionColors.primary,
              size: 40,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'No pending requests',
            style: theme.textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'When someone sends you a\nfriend request, it will appear here',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final FriendRequest request;
  final int index;
  final Future<bool> Function() onAccept;
  final Future<bool> Function() onDecline;

  const _RequestCard({
    required this.request,
    required this.index,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _acceptLoading = false;
  bool _declineLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sender = widget.request.sender;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? LionColors.cardDark : LionColors.cardLight,
          borderRadius: BorderRadius.circular(LionRadius.lg),
          border: Border.all(
            color: isDark ? LionColors.borderDark : LionColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: sender.avatarUrl,
              name: sender.displayName,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '@${sender.username}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeago.format(widget.request.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _RequestButton(
                  label: 'Accept',
                  isLoading: _acceptLoading,
                  isPrimary: true,
                  onTap: () async {
                    setState(() => _acceptLoading = true);
                    await widget.onAccept();
                    setState(() => _acceptLoading = false);
                  },
                ),
                const SizedBox(height: 6),
                _RequestButton(
                  label: 'Decline',
                  isLoading: _declineLoading,
                  isPrimary: false,
                  onTap: () async {
                    setState(() => _declineLoading = true);
                    await widget.onDecline();
                    setState(() => _declineLoading = false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 80))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms);
  }
}

class _RequestButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RequestButton({
    required this.label,
    required this.isLoading,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          gradient: isPrimary ? LionColors.primaryGradient : null,
          color: isPrimary
              ? null
              : theme.colorScheme.outline.withOpacity(0.15),
          borderRadius: BorderRadius.circular(LionRadius.sm),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: isPrimary
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: isPrimary
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
