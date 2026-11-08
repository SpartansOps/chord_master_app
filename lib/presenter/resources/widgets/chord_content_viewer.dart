import 'package:flutter/material.dart';

class ChordContentViewer extends StatelessWidget {
  final String? intro;
  final String? content;
  final double fontSize;

  const ChordContentViewer({
    super.key,
    this.intro,
    this.content,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chordColor = isDark ? const Color(0xFF7C9CC4) : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intro != null && intro!.isNotEmpty) ...[
          Text(
            'INTRO',
            style: TextStyle(
              fontSize: fontSize * 0.75,
              fontWeight: FontWeight.bold,
              color: chordColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro!,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: chordColor,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (content != null && content!.isNotEmpty)
          _buildFormattedContent(context, content!, fontSize, chordColor),
      ],
    );
  }

  Widget _buildFormattedContent(
    BuildContext context,
    String text,
    double fontSize,
    Color chordColor,
  ) {
    final lines = text.split('\n');
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return SizedBox(height: fontSize * 0.8);
        }

        final isChordLine = _isChordLine(line);

        if (isChordLine) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: TextStyle(
                fontSize: fontSize,
                color: chordColor,
                height: 1.6,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            line,
            style: TextStyle(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isChordLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;

    final tokens = trimmed.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return false;

    final chordRegex = RegExp(
      r'^[A-G][#b]?(m|min|maj|M|dim|aug|sus|add|maj7|min7|m7|7|9|11|13|maj9|min9|m9|dim7|aug7|sus2|sus4|m7b5|maj7#5|add9|add11|add13)?(\/[A-G][#b]?)?$',
    );

    int chordCount = 0;
    int nonEmptyCount = 0;

    for (final token in tokens) {
      if (token.isEmpty) continue;
      nonEmptyCount++;

      final cleanToken = token.replaceAll(RegExp(r'^[(),]+|[(),]+$'), '');
      if (chordRegex.hasMatch(cleanToken)) {
        chordCount++;
      }
    }

    if (nonEmptyCount == 0) return false;
    return chordCount > 0 && chordCount >= nonEmptyCount * 0.5;
  }
}
