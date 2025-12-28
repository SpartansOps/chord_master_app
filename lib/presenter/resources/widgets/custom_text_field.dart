import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.suffixIcon,
    this.contentPadding,
    this.onChanged,
    this.prefixIcon,
    this.textInputType,
    this.maxLines,
    this.validator,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double? contentPadding;
  final TextInputType? textInputType;
  final int? maxLines;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorHeight: 20.0,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.all(contentPadding ?? 16.0),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: textInputType,
      validator: validator,
    );
  }
}
