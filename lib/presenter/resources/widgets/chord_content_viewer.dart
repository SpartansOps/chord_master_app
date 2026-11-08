import 'package:chord_master_app/domain/utils/chord_markup.dart';
import 'package:chord_master_app/presenter/design_system/tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renderiza o conteúdo de uma cifra.
///
/// IMPORTANTE: as fontes da cifra são fixas e não seguem o tema do app:
/// - cifras do app: Roboto (fonte padrão original);
/// - cifras do Cifra Club: Roboto Mono.
/// Só as cores vêm do design system.
class ChordContentViewer extends StatelessWidget {
  const ChordContentViewer({
    super.key,
    this.intro,
    this.content,
    required this.fontSize,
    this.cifraClub = false,
  });

  final String? intro;
  final String? content;
  final double fontSize;

  /// Conteúdo em HTML do Cifra Club (acordes em `<b>`).
  final bool cifraClub;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (cifraClub) {
      final text = content ?? '';
      // Cifra importada e editada no app vira texto puro, mas continua
      // no visual do Cifra Club (Roboto Mono), com as linhas de acorde destacadas.
      final spans = ChordMarkup.isHtml(text)
          ? _cifraClubSpans(text, c)
          : _cifraClubPlainSpans(text, c);
      return SelectionArea(child: Text.rich(TextSpan(children: spans)));
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intro != null && intro!.isNotEmpty) ...[
            Text(
              'INTRO',
              style: GoogleFonts.roboto(
                fontSize: fontSize * 0.75,
                fontWeight: FontWeight.bold,
                color: c.chord,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              intro!,
              style: GoogleFonts.roboto(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: c.chord,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (content != null && content!.isNotEmpty) ..._plainLines(content!, c),
        ],
      ),
    );
  }

  List<Widget> _plainLines(String text, AppColors c) {
    return text.split('\n').map((line) {
      if (line.trim().isEmpty) return SizedBox(height: fontSize * 0.8);
      final isChord = ChordMarkup.isChordLine(line);
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          line,
          style: GoogleFonts.roboto(
            fontSize: fontSize,
            color: isChord ? c.chord : c.text,
            height: 1.6,
          ),
        ),
      );
    }).toList();
  }

  List<TextSpan> _cifraClubPlainSpans(String text, AppColors c) {
    final defaultStyle = GoogleFonts.robotoMono(fontSize: fontSize, color: c.text, height: 1.5);
    final chordStyle = defaultStyle.copyWith(color: c.chord, fontWeight: FontWeight.bold);
    final lines = text.split('\n');
    return [
      for (var i = 0; i < lines.length; i++)
        TextSpan(
          text: i < lines.length - 1 ? '${lines[i]}\n' : lines[i],
          style: ChordMarkup.isChordLine(lines[i]) ? chordStyle : defaultStyle,
        ),
    ];
  }

  List<TextSpan> _cifraClubSpans(String html, AppColors c) {
    if (html.isEmpty) return [];
    final normalized = ChordMarkup.normalizeCifraClubHtml(html)
        .replaceAll('‹', '<')
        .replaceAll('›', '>');

    final defaultStyle = GoogleFonts.robotoMono(fontSize: fontSize, color: c.text, height: 1.5);
    final chordStyle = GoogleFonts.robotoMono(
      fontSize: fontSize,
      color: c.chord,
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    final spans = <TextSpan>[];
    var last = 0;
    for (final match in RegExp(r'<b[^>]*>(.*?)</b>').allMatches(normalized)) {
      if (match.start > last) {
        spans.add(TextSpan(text: normalized.substring(last, match.start), style: defaultStyle));
      }
      spans.add(TextSpan(text: match.group(1), style: chordStyle));
      last = match.end;
    }
    if (last < normalized.length) {
      spans.add(TextSpan(text: normalized.substring(last), style: defaultStyle));
    }
    return spans;
  }
}
