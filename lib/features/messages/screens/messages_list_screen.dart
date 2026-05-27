import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/messages_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../features/auth/providers/auth_provider.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().loadConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      body: Column(
        children: [
          _buildSearchBar(theme, isDark),
          Expanded(child: _buildBody(theme, isDark)),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      title: const Text('Messages'),
      actions: [
        IconButton(
          onPressed: () => context.go('/home/settings'),
          icon: const Icon(Icons.settings_outlined, size: 22),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E35)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(LionRadius.full),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    return Consumer<MessagesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.conversations.isEmpty) {
          return _buildShimmer();
        }

        final filtered = provider.conversations
            .where((c) =>
                _searchQuery.isEmpty ||
                c.userName.toLowerCase().contains(_searchQuery))
            .toList();

        if (filtered.isEmpty) {
          return _buildEmpty(theme);
        }

        return RefreshIndicator(
          color: LionColors.primary,
          onRefresh: () => provider.loadConversations(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _ConversationTile(
              conversation: filtered[index],
              index: index,
            ),
          ),
        );
      },
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
                    width: 140,
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
                    width: 200,
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
              Icons.chat_bubble_outline_rounded,
              color: LionColors.primary,
              size: 40,
            ),
          ).animate().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: theme.textTheme.headlineSmall,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by adding\na friend first',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/home/search'),
      backgroundColor: LionColors.primary,
      elevation: 4,
      child: const Icon(Icons.edit_rounded, color: Colors.white),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          delay: 300.ms,
        );
  }
}

class _ConversationTile extends StatefulWidget {
  final Conversation conversation;
  final int index;

  const _ConversationTile({
    required this.conversation,
    required this.index,
  });

  @override
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final c = widget.conversation;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.go(
          '/home/chat/${c.id}',
          extra: {
            'name': c.userName,
            'avatar': c.userAvatar,
            'userId': c.userId,
          },
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _isPressed
            ? (isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: c.userAvatar,
              name: c.userName,
              size: 52,
              showOnline: true,
              isOnline: c.isOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: c.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.lastMessageTime != null)
                        Text(
                          timeago.format(c.lastMessageTime!, locale: 'en_short'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.unreadCount > 0
                                ? LionColors.primary
                                : theme.colorScheme.onSurface.withOpacity(0.4),
                            fontWeight: c.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.lastMessage ?? 'Start a conversation',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: c.unreadCount > 0
                                ? theme.colorScheme.onSurface.withOpacity(0.85)
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: c.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: LionColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            c.unreadCount > 99
                                ? '99+'
                                : c.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 40))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }
}
