import 'package:chord_master_app/domain/chord.dart';
import 'package:chord_master_app/domain/utils/chord_transposer.dart';

/// Utilitários para o conteúdo das cifras.
///
/// Existem dois formatos de conteúdo:
/// - texto puro: acordes em linhas próprias, acima da letra;
/// - HTML do Cifra Club: o `<pre>` do site, acordes dentro de `<b>`.
///
/// E dois modos de exibição (regra herdada do app): cifras com link do
/// Cifra Club usam Roboto Mono; as demais usam Roboto.
abstract class ChordMarkup {
  static bool isCifraClub(Chord chord) =>
      (chord.chordLink ?? '').contains('cifraclub.com.br');

  static bool isHtml(String content) => content.contains(RegExp(r'<b[\s>]'));

  /// Retorna uma cópia da cifra transposta em [semitones].
  static Chord transpose(Chord chord, int semitones) {
    if (semitones == 0) return chord;
    return chord.copyWith(
      chordContent: transposeContent(chord.chordContent ?? '', semitones),
      chordIntro: ChordTransposer.transposePlainText(chord.chordIntro ?? '', semitones),
    );
  }

  static String transposeContent(String content, int semitones) => isHtml(content)
      ? ChordTransposer.transposeHtml(content, semitones)
      : ChordTransposer.transposePlainText(content, semitones);

  /// Nota do primeiro acorde da cifra (aproximação do tom), ex.: "G", "F#".
  static String? firstChordRoot(Chord chord) {
    final content = chord.chordContent ?? '';
    final root = RegExp(r'^\(?([A-G][#b]?)');
    if (isHtml(content)) {
      for (final m in RegExp(r'<b[^>]*>(.*?)</b>').allMatches(content)) {
        final r = root.firstMatch((m.group(1) ?? '').trim());
        if (r != null) return r.group(1);
      }
      return null;
    }
    final intro = chord.chordIntro ?? '';
    for (final line in [...intro.split('\n'), ...content.split('\n')]) {
      if (!isChordLine(line)) continue;
      final r = root.firstMatch(line.trim());
      if (r != null) return r.group(1);
    }
    return null;
  }

  /// Normaliza o HTML do Cifra Club deixando apenas as tags `<b>` (acordes).
  /// `<` e `>` literais viram ‹ e › para não serem confundidos com tags.
  static String normalizeCifraClubHtml(String html) {
    var out = html
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '‹')
        .replaceAll('&gt;', '›');
    out = out.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    out = out.replaceAll(RegExp(r'</div>'), '\n');
    // Remove todas as tags, exceto <b> e </b>
    out = out.replaceAll(RegExp(r'</?(?!b\b)[a-zA-Z0-9]+[^>]*>'), '');
    return out;
  }

  /// Converte HTML do Cifra Club em texto puro (para o editor).
  static String toPlainText(String content) {
    if (!isHtml(content) && !content.contains('<')) return content;
    return normalizeCifraClubHtml(content)
        .replaceAll(RegExp(r'<b[^>]*>'), '')
        .replaceAll('</b>', '')
        .replaceAll('‹', '<')
        .replaceAll('›', '>');
  }

  /// Linha "de acordes" no formato texto puro.
  static bool isChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;

    final tokens = trimmed.split(RegExp(r'\s+'));
    var chordCount = 0;
    var nonEmptyCount = 0;

    for (final token in tokens) {
      if (token.isEmpty) continue;
      nonEmptyCount++;
      final cleanToken = token.replaceAll(RegExp(r'^[(),]+|[(),]+$'), '');
      if (_chordRegex.hasMatch(cleanToken)) chordCount++;
    }

    if (nonEmptyCount == 0) return false;
    return chordCount > 0 && chordCount >= nonEmptyCount * 0.5;
  }

  static final _chordRegex = RegExp(
    r'^[A-G][#b]?(m|min|maj|M|dim|aug|sus|add|maj7|min7|m7|7|9|11|13|maj9|min9|m9|dim7|aug7|sus2|sus4|m7b5|maj7#5|add9|add11|add13)?(\/[A-G][#b]?)?$',
  );
}
