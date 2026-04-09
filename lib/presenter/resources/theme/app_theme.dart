import 'package:chord_master_app/domain/settings.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme(Settings settings) => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6A00FF),
        brightness: settings.darkMode ? Brightness.dark : Brightness.light,
      ),
    );
