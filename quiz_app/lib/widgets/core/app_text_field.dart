import 'package:flutter/material.dart';

import '../../utils/color.dart';
import '../../utils/quiz_design_system.dart';

/// Custom TextField component with consistent styling
/// Provides AppColors integration and standardized appearance
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: _obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      validator: widget.validator,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.8),
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),

        // Prefix icon
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.iconInactive, size: 20)
            : null,

        // Suffix icon (with password visibility toggle support)
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.iconInactive,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon != null
            ? IconButton(
                icon: Icon(
                  widget.suffixIcon,
                  color: AppColors.iconInactive,
                  size: 20,
                ),
                onPressed: widget.onSuffixIconPressed,
              )
            : null,

        // Border styling
        filled: true,
        fillColor: widget.enabled
            ? AppColors.white
            : AppColors.disabledBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: QuizSpacing.md,
          vertical: QuizSpacing.md,
        ),

        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),

        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),

        // Disabled border
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
