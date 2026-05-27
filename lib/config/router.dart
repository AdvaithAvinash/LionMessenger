import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/messages/screens/chat_screen.dart';
import '../features/friends/screens/search_users_screen.dart';
import '../features/friends/screens/friend_requests_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/privacy_screen.dart';
import '../features/settings/screens/blocked_users_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => _fadeTransition(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => _slideTransition(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _slideTransition(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      pageBuilder: (context, state) => _slideTransition(
        key: state.pageKey,
        child: const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _fadeTransition(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'chat/:channelId',
          name: 'chat',
          pageBuilder: (context, state) => _slideTransition(
            key: state.pageKey,
            child: ChatScreen(
              channelId: state.pathParameters['channelId']!,
              userName: state.uri.queryParameters['name'] ?? 'User',
              userAvatar: state.uri.queryParameters['avatar'],
              userId: state.uri.queryParameters['userId'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: 'search',
          name: 'search',
          pageBuilder: (context, state) => _slideTransition(
            key: state.pageKey,
            child: const SearchUsersScreen(),
          ),
        ),
        GoRoute(
          path: 'friend-requests',
          name: 'friend-requests',
          pageBuilder: (context, state) => _slideTransition(
            key: state.pageKey,
            child: const FriendRequestsScreen(),
          ),
        ),
        GoRoute(
          path: 'profile/:userId',
          name: 'profile',
          pageBuilder: (context, state) => _slideTransition(
            key: state.pageKey,
            child: ProfileScreen(userId: state.pathParameters['userId']!),
          ),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          pageBuilder: (context, state) => _slideTransition(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'privacy',
              name: 'privacy',
              pageBuilder: (context, state) => _slideTransition(
                key: state.pageKey,
                child: const PrivacyScreen(),
              ),
            ),
            GoRoute(
              path: 'blocked',
              name: 'blocked',
              pageBuilder: (context, state) => _slideTransition(
                key: state.pageKey,
                child: const BlockedUsersScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

CustomTransitionPage _fadeTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage _slideTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}
