import 'package:chord_master_app/domain/settings.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme(Settings settings) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightGreen,
        brightness: settings.darkMode ? Brightness.dark : Brightness.light,
      ),
    );
