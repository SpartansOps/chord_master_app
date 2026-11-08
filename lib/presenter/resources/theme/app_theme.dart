import 'package:chord_master_app/domain/settings.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme(Settings settings) {
  final isDark = settings.darkMode;

  // Azul suave que não agride os olhos
  const primaryColor = Color(0xFF4A6FA5);
  const primaryLight = Color(0xFF6B8FC5);
  const primaryDark = Color(0xFF345A8A);

  // Cores de superfície mais suaves
  const surfaceLight = Color(0xFFF8FAFC);
  const surfaceDark = Color(0xFF1A1F2E);

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,

    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: isDark ? primaryDark.withValues(alpha: 0.3) : primaryLight.withValues(alpha: 0.15),
      onPrimaryContainer: isDark ? Colors.white : primaryDark,
      secondary: const Color(0xFF7C9CC4),
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF5A7A9E).withValues(alpha: 0.3) : const Color(0xFFB8D0E8).withValues(alpha: 0.3),
      onSecondaryContainer: isDark ? Colors.white : const Color(0xFF2C4A6E),
      surface: isDark ? surfaceDark : surfaceLight,
      onSurface: isDark ? Colors.white : const Color(0xFF1E293B),
      onSurfaceVariant: isDark ? Colors.white70 : const Color(0xFF64748B),
      outline: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
      outlineVariant: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
      error: const Color(0xFFDC2626),
      onError: Colors.white,
    ),

    // Scaffold sem cor de fundo padrão
    scaffoldBackgroundColor: isDark ? surfaceDark : surfaceLight,

    // AppBar personalizada
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? surfaceDark : surfaceLight,
      foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
    ),

    // Cards sem elevação
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF242938) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // ListTile mais limpo
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
      ),
    ),

    // Botões mais suaves
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // Input fields mais limpos
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF242938) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
      ),
    ),

    // FloatingActionButton mais suave
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    // BottomSheet mais limpo
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? const Color(0xFF242938) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    ),

    // PopupMenu mais limpo
    popupMenuTheme: PopupMenuThemeData(
      color: isDark ? const Color(0xFF242938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Divider mais sutil
    dividerTheme: DividerThemeData(
      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
      thickness: 1,
    ),

    // TextTheme mais limpo
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : const Color(0xFF334155),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white70 : const Color(0xFF475569),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
      ),
    ),
  );
}
