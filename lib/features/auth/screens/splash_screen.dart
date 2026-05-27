import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../config/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();

    if (!mounted) return;
    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LionColors.splashGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 28),
              _buildAppName(),
              const SizedBox(height: 12),
              _buildTagline(),
              const SizedBox(height: 80),
              _buildLoader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LionColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: LionColors.primary.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.chat_bubble_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAppName() {
    return Text(
      'LionMessenger',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    )
        .animate(delay: 300.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildTagline() {
    return Text(
      'Connect without limits',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.6),
        letterSpacing: 0.3,
      ),
    )
        .animate(delay: 450.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        color: LionColors.primary.withOpacity(0.7),
        strokeWidth: 2.5,
      ),
    ).animate(delay: 800.ms).fadeIn(duration: 400.ms);
  }
}
