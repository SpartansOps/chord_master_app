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
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? suffixIcon;
  final double? contentPadding;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorHeight: 20.0,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.all(contentPadding ?? 16.0),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
