import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bgController;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Chat Without\nPhone Numbers',
      description:
          'Connect with anyone using just your email. No SIM card or phone number ever required.',
      gradient: const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      bgColor: const Color(0xFF1A1830),
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      title: 'Build Your\nFriend Network',
      description:
          'Send friend requests, grow your circle, and control exactly who can reach you.',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6584), Color(0xFFFF3366)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      bgColor: const Color(0xFF1E1220),
    ),
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: 'Your Privacy,\nYour Rules',
      description:
          'Block users, restrict who messages you, and stay in full control of your experience.',
      gradient: const LinearGradient(
        colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      bgColor: const Color(0xFF0E1C16),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _pages[_currentPage].bgColor,
              LionColors.backgroundDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) =>
                      _buildPage(_pages[index], index),
                ),
              ),
              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _buildIllustration(page, index),
          const Spacer(),
          _buildText(page, index),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildIllustration(_OnboardingPage page, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow behind icon
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.gradient.colors.first.withOpacity(0.1),
          ),
        ),
        // Icon container
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            gradient: page.gradient,
            borderRadius: BorderRadius.circular(44),
            boxShadow: [
              BoxShadow(
                color: page.gradient.colors.first.withOpacity(0.45),
                blurRadius: 48,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            page.icon,
            color: Colors.white,
            size: 72,
          ),
        )
            .animate(key: ValueKey('icon_$index'))
            .scale(
              begin: const Offset(0.75, 0.75),
              end: const Offset(1.0, 1.0),
              duration: 550.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildText(_OnboardingPage page, int index) {
    return Column(
      children: [
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        )
            .animate(key: ValueKey('title_$index'))
            .fadeIn(duration: 450.ms, delay: 100.ms)
            .slideY(
                begin: 0.2,
                end: 0,
                duration: 450.ms,
                delay: 100.ms,
                curve: Curves.easeOut),
        const SizedBox(height: 18),
        Text(
          page.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.6),
            height: 1.65,
          ),
        )
            .animate(key: ValueKey('desc_$index'))
            .fadeIn(duration: 450.ms, delay: 200.ms)
            .slideY(
                begin: 0.15,
                end: 0,
                duration: 450.ms,
                delay: 200.ms,
                curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: i == _currentPage
                      ? _pages[_currentPage].gradient
                      : null,
                  color:
                      i == _currentPage ? null : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Next / Get Started button
          GestureDetector(
            onTap: _next,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _pages[_currentPage].gradient,
                borderRadius: BorderRadius.circular(LionRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color:
                        _pages[_currentPage].gradient.colors.first.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage < _pages.length - 1
                          ? 'Continue'
                          : 'Get Started',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: _pages[_currentPage].gradient.colors.first,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
  final Color bgColor;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.bgColor,
  });
}
