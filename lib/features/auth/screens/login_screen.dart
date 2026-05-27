import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/lion_button.dart';
import '../../../shared/widgets/lion_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildBackButton(context),
                    const SizedBox(height: 48),
                    _buildHeader(theme),
                    const SizedBox(height: 40),
                    _buildForm(theme),
                    const SizedBox(height: 32),
                    _buildSignInButton(),
                    const SizedBox(height: 24),
                    _buildDivider(theme),
                    const SizedBox(height: 24),
                    _buildSignUpLink(context, theme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? LionColors.splashGradient : null,
        color: isDark ? null : LionColors.backgroundLight,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/onboarding'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(LionRadius.sm),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: theme.textTheme.displayMedium?.copyWith(
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              delay: 100.ms,
            ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue to LionMessenger',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Column(
        children: [
          if (auth.error != null) ...[
            _ErrorBanner(message: auth.error!),
            const SizedBox(height: 16),
          ],
          _buildFormField(
            hint: 'your@email.com',
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            hint: '••••••••',
            label: 'Password',
            controller: _passwordController,
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot password?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: LionColors.primaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String hint,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              maxWidth: 52,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: const BorderSide(
                color: LionColors.primaryLight,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: const BorderSide(color: LionColors.busy, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: const BorderSide(color: LionColors.busy, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 300.ms);
  }

  Widget _buildSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => LionButton(
        label: 'Sign In',
        onPressed: auth.isLoading ? null : _signIn,
        isLoading: auth.isLoading,
      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildSignUpLink(BuildContext context, ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/signup'),
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: const TextStyle(
                  color: LionColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LionColors.busy.withOpacity(0.15),
        borderRadius: BorderRadius.circular(LionRadius.sm),
        border: Border.all(color: LionColors.busy.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: LionColors.busy, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake(hz: 3, offset: const Offset(4, 0));
  }
}
