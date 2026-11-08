import 'package:chord_master_app/presenter/design_system/tokens.dart';
import 'package:flutter/material.dart';

/// Campo de texto com rótulo acima (não flutuante).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.minLines,
    this.maxLines = 1,
    this.obscureText = false,
    this.autofocus = false,
    this.style,
    this.errorText,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? minLines;
  final int? maxLines;
  final bool obscureText;
  final bool autofocus;

  /// Estilo do texto digitado (ex.: editor de cifra usa a fonte da cifra).
  final TextStyle? style;
  final String? errorText;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      keyboardType: keyboardType ?? (maxLines != 1 ? TextInputType.multiline : null),
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      autofocus: autofocus,
      style: style ?? context.text.body,
      cursorColor: c.accent,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffixIcon: suffix,
        alignLabelWithHint: true,
      ),
    );

    if (label == null && helper == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: context.text.caption.copyWith(color: c.text)),
          const SizedBox(height: 6),
        ],
        field,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: context.text.caption.copyWith(color: c.textFaint, fontSize: 12)),
        ],
      ],
    );
  }
}
