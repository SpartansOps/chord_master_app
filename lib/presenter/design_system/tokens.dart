import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "palco": grafite quente + âmbar. Toda cor usada nas telas vem daqui.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.chord,
    required this.danger,
    required this.dangerSoft,
    required this.success,
    required this.successSoft,
    required this.scrim,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;

  /// Cor dos acordes na leitura da cifra.
  final Color chord;
  final Color danger;
  final Color dangerSoft;
  final Color success;
  final Color successSoft;
  final Color scrim;

  static const dark = AppColors(
    background: Color(0xFF110F0D),
    surface: Color(0xFF1A1815),
    surfaceAlt: Color(0xFF24211D),
    border: Color(0xFF2E2A25),
    borderStrong: Color(0xFF48423A),
    text: Color(0xFFF3EEE6),
    textMuted: Color(0xFFA69E91),
    textFaint: Color(0xFF6F685E),
    accent: Color(0xFFF5A524),
    accentSoft: Color(0x24F5A524),
    onAccent: Color(0xFF16130F),
    chord: Color(0xFFF5B13D),
    danger: Color(0xFFF26D5B),
    dangerSoft: Color(0x24F26D5B),
    success: Color(0xFF5FC98A),
    successSoft: Color(0x245FC98A),
    scrim: Color(0xB3000000),
  );

  static const light = AppColors(
    background: Color(0xFFF6F3ED),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEE9E0),
    border: Color(0xFFE5DED2),
    borderStrong: Color(0xFFCFC6B7),
    text: Color(0xFF1B1814),
    textMuted: Color(0xFF6B6358),
    textFaint: Color(0xFFA0978A),
    accent: Color(0xFFEC960F),
    accentSoft: Color(0x24EC960F),
    onAccent: Color(0xFF16130F),
    chord: Color(0xFFB4580A),
    danger: Color(0xFFC93A2B),
    dangerSoft: Color(0x1FC93A2B),
    success: Color(0xFF23854F),
    successSoft: Color(0x1F23854F),
    scrim: Color(0x80000000),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccent: l(onAccent, other.onAccent),
      chord: l(chord, other.chord),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      scrim: l(scrim, other.scrim),
    );
  }
}

abstract class AppSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Margem lateral padrão das telas.
  static const double gutter = 16;

  /// Largura máxima do conteúdo em telas grandes.
  static const double maxContentWidth = 760;
}

abstract class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

abstract class AppDurations {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 220);
}

/// Estilos de texto da interface (Manrope). A cifra NÃO usa estes estilos:
/// ela mantém as fontes originais (ver ChordContentViewer).
class AppTextStyles {
  AppTextStyles(this._c);

  final AppColors _c;

  static TextStyle get _base => GoogleFonts.manrope();

  TextStyle get display => _base.copyWith(
      fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.6, color: _c.text);
  TextStyle get title => _base.copyWith(
      fontSize: 20, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.3, color: _c.text);
  TextStyle get subtitle => _base.copyWith(
      fontSize: 16, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.1, color: _c.text);
  TextStyle get body =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: _c.text);
  TextStyle get bodyMuted => body.copyWith(color: _c.textMuted);
  TextStyle get caption =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35, color: _c.textMuted);
  TextStyle get label => _base.copyWith(
      fontSize: 11, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: 1.1, color: _c.textMuted);
  TextStyle get button =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.1);
  TextStyle get number => _base.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: _c.text);
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.dark;
  AppTextStyles get text => AppTextStyles(colors);
  bool get isWide => MediaQuery.sizeOf(this).width >= 900;
}
