import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String content,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      action: action,
    ),
  );
}
