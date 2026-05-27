import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/constants.dart';

enum LionButtonVariant { primary, secondary, outline, ghost, danger }

class LionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final LionButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? height;

  const LionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LionButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 52,
  });

  @override
  State<LionButton> createState() => _LionButtonState();
}

class _LionButtonState extends State<LionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: (_) {
        if (!isDisabled) setState(() => _scale = 0.97);
      },
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        if (!isDisabled) widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: _buildButton(context, isDisabled),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    final theme = Theme.of(context);

    switch (widget.variant) {
      case LionButtonVariant.primary:
        return _GradientButton(
          label: widget.label,
          isLoading: widget.isLoading,
          isDisabled: isDisabled,
          fullWidth: widget.fullWidth,
          height: widget.height!,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          gradient: LionColors.primaryGradient,
        );

      case LionButtonVariant.secondary:
        return Container(
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: LionColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(LionRadius.md),
          ),
          child: _ButtonContent(
            label: widget.label,
            isLoading: widget.isLoading,
            color: LionColors.primary,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        );

      case LionButtonVariant.outline:
        return Container(
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled
                  ? theme.colorScheme.outline
                  : LionColors.primary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(LionRadius.md),
          ),
          child: _ButtonContent(
            label: widget.label,
            isLoading: widget.isLoading,
            color: isDisabled
                ? theme.colorScheme.outline
                : LionColors.primary,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        );

      case LionButtonVariant.ghost:
        return SizedBox(
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          child: _ButtonContent(
            label: widget.label,
            isLoading: widget.isLoading,
            color: LionColors.primary,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        );

      case LionButtonVariant.danger:
        return Container(
          height: widget.height,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: LionColors.busy,
            borderRadius: BorderRadius.circular(LionRadius.md),
          ),
          child: _ButtonContent(
            label: widget.label,
            isLoading: widget.isLoading,
            color: Colors.white,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
        );
    }
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final double height;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Gradient gradient;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    required this.fullWidth,
    required this.height,
    this.prefixIcon,
    this.suffixIcon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: isDisabled ? null : gradient,
        color: isDisabled ? LionColors.primary.withOpacity(0.4) : null,
        borderRadius: BorderRadius.circular(LionRadius.md),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: LionColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        color: Colors.white,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color color;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.color,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, color: color, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                      ),
                ),
                if (suffixIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(suffixIcon, color: color, size: 18),
                ],
              ],
            ),
    );
  }
}

class LionIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final String? tooltip;
  final bool hasBackground;

  const LionIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 24,
    this.tooltip,
    this.hasBackground = false,
  });

  @override
  State<LionIconButton> createState() => _LionIconButtonState();
}

class _LionIconButtonState extends State<LionIconButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        widget.color ?? theme.iconTheme.color ?? theme.colorScheme.onSurface;

    final button = GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.all(widget.hasBackground ? 8 : 0),
          decoration: widget.hasBackground
              ? BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(LionRadius.sm),
                )
              : null,
          child: Icon(widget.icon, color: iconColor, size: widget.size),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
