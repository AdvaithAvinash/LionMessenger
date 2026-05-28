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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _init();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2200));
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
        decoration: const BoxDecoration(gradient: LionColors.splashGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoWithPulse(),
              const SizedBox(height: 32),
              _buildAppName(),
              const SizedBox(height: 10),
              _buildTagline(),
              const SizedBox(height: 80),
              _buildLoader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoWithPulse() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring 1
          _PulseRing(
            controller: _pulseController,
            delay: 0.0,
            baseSize: 96,
            maxScale: 2.2,
            opacity: 0.18,
          ),
          // Pulse ring 2
          _PulseRing(
            controller: _pulseController,
            delay: 0.33,
            baseSize: 96,
            maxScale: 2.2,
            opacity: 0.12,
          ),
          // Pulse ring 3
          _PulseRing(
            controller: _pulseController,
            delay: 0.66,
            baseSize: 96,
            maxScale: 2.2,
            opacity: 0.07,
          ),
          // Logo
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LionColors.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: LionColors.primary.withOpacity(0.55),
                  blurRadius: 40,
                  spreadRadius: 4,
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
                begin: const Offset(0.4, 0.4),
                end: const Offset(1.0, 1.0),
                duration: 700.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFD4CFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'LionMessenger',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    )
        .animate(delay: 350.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildTagline() {
    return Text(
      'Connect without limits',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.55),
        letterSpacing: 0.5,
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildLoader() {
    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: LionColors.primary.withOpacity(0.7),
            strokeWidth: 2.5,
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ).animate(delay: 900.ms).fadeIn(duration: 400.ms);
  }
}

class _PulseRing extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final double baseSize;
  final double maxScale;
  final double opacity;

  const _PulseRing({
    required this.controller,
    required this.delay,
    required this.baseSize,
    required this.maxScale,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double progress = (controller.value + delay) % 1.0;
        final scale = 1.0 + progress * (maxScale - 1.0);
        final alpha = (opacity * (1.0 - progress)).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LionColors.primary.withOpacity(alpha),
            ),
          ),
        );
      },
    );
  }
}
