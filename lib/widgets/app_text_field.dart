import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Text field with its label above it (mockup «Kirish»): 56 high,
/// radius-md, 1.5 border that turns brand-500 on focus.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.fieldKey,
    this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final Key? fieldKey;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final int? minLines;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppText.label.copyWith(color: context.colors.ink)),
        const SizedBox(height: AppSpace.labelGap),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          style: AppText.input.copyWith(color: context.colors.ink),
          validator: validator,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            constraints: maxLines == 1
                ? const BoxConstraints(minHeight: AppSize.input)
                : null,
          ),
        ),
      ],
    );
  }
}
