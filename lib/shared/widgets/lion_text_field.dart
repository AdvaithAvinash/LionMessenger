import 'package:flutter/material.dart';
import '../../config/constants.dart';

class LionTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final int? maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const LionTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<LionTextField> createState() => _LionTextFieldState();
}

class _LionTextFieldState extends State<LionTextField> {
  bool _obscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _isFocused
                  ? LionColors.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText ? _obscured : false,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            autofocus: widget.autofocus,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? LionColors.primary
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        size: 20,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                maxWidth: 52,
              ),
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: () => setState(() => _obscured = !_obscured),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(
                          _obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          size: 20,
                        ),
                      ),
                    )
                  : widget.suffix != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: widget.suffix,
                        )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}

class LionSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const LionSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E35)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(LionRadius.full),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? GestureDetector(
                  onTap: () {
                    controller?.clear();
                    onClear?.call();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
