import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/lion_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Chat Without\nPhone Numbers',
      description:
          'Connect with people using just your email. No phone number needed — ever.',
      gradient: const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
      ),
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      title: 'Build Your\nFriend Network',
      description:
          'Send friend requests, build your circle, and control who can message you.',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6584), Color(0xFFFF3366)],
      ),
    ),
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: 'Your Privacy,\nYour Rules',
      description:
          'Block anyone, set message privacy, and stay in control of your experience.',
      gradient: const LinearGradient(
        colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _buildPage(_pages[index], index),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return Container(
      decoration: BoxDecoration(gradient: LionColors.splashGradient),
      child: SafeArea(
        child: Padding(
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
        ),
      ),
    );
  }

  Widget _buildIllustration(_OnboardingPage page, int index) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: page.gradient,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: (page.gradient.colors.first).withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        page.icon,
        color: Colors.white,
        size: 80,
      ),
    )
        .animate(key: ValueKey('icon_$index'))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildText(_OnboardingPage page, int index) {
    return Column(
      children: [
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        )
            .animate(key: ValueKey('title_$index'))
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 16),
        Text(
          page.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.65),
            height: 1.6,
          ),
        )
            .animate(key: ValueKey('desc_$index'))
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (_currentPage < _pages.length - 1)
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: _currentPage < _pages.length - 1 ? 2 : 1,
                    child: GestureDetector(
                      onTap: _next,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LionColors.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(LionRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: LionColors.primary.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _currentPage < _pages.length - 1
                                ? 'Next'
                                : 'Get Started',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
