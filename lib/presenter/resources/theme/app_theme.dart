import 'package:chord_master_app/domain/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getApplicationTheme(Settings settings) => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6A00FF),
        brightness: settings.darkMode ? Brightness.dark : Brightness.light,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
