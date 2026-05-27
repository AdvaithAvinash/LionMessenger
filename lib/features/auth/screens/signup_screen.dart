import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/lion_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim().toLowerCase(),
      displayName: _displayNameController.text.trim(),
    );
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LionColors.splashGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildBack(context),
                  const SizedBox(height: 40),
                  _buildHeader(theme),
                  const SizedBox(height: 36),
                  _buildError(),
                  _buildFields(),
                  const SizedBox(height: 32),
                  _buildSignUpButton(),
                  const SizedBox(height: 28),
                  _buildLoginLink(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/login'),
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
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          'Join LionMessenger today — no phone needed',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.6),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildError() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => auth.error != null
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: LionColors.busy.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(LionRadius.sm),
                    border: Border.all(
                      color: LionColors.busy.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: LionColors.busy, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.error!,
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(),
                const SizedBox(height: 16),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        _field(
          'Full Name',
          'John Doe',
          _displayNameController,
          Icons.person_outline_rounded,
          delay: 300,
          validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: 14),
        _field(
          'Username',
          'johndoe',
          _usernameController,
          Icons.alternate_email_rounded,
          delay: 350,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Username is required';
            if (v.length < 3) return 'At least 3 characters';
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
              return 'Letters, numbers, underscores only';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        _field(
          'Email',
          'your@email.com',
          _emailController,
          Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          delay: 400,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _field(
          'Password',
          '••••••••',
          _passwordController,
          Icons.lock_outline_rounded,
          obscureText: true,
          delay: 450,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 8) return 'At least 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _field(
          'Confirm Password',
          '••••••••',
          _confirmPasswordController,
          Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signUp(),
          delay: 500,
          validator: (v) {
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
    int delay = 300,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
              color: Colors.white.withOpacity(0.3),
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(icon,
                  color: Colors.white.withOpacity(0.4), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              maxWidth: 52,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide: const BorderSide(
                  color: LionColors.primaryLight, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide:
                  const BorderSide(color: LionColors.busy, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LionRadius.md),
              borderSide:
                  const BorderSide(color: LionColors.busy, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay)).slideY(begin: 0.1, end: 0, duration: 400.ms, delay: Duration(milliseconds: delay));
  }

  Widget _buildSignUpButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => GestureDetector(
        onTap: auth.isLoading ? null : _signUp,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: auth.isLoading
                ? null
                : LionColors.primaryGradient,
            color: auth.isLoading
                ? LionColors.primary.withOpacity(0.4)
                : null,
            borderRadius: BorderRadius.circular(LionRadius.md),
            boxShadow: auth.isLoading
                ? null
                : [
                    BoxShadow(
                      color: LionColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: auth.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ).animate().fadeIn(delay: 550.ms),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            children: const [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: LionColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
