import 'package:chord_master_app/domain/settings.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme(Settings settings) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightBlue,
        brightness: settings.darkMode ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
    );
