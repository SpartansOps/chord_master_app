class ChordTransposer {
  static final List<String> _scale = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  static final List<String> _flatScale = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];

  static String transposeHtml(String html, int semitones) {
    if (semitones == 0) return html;

    // Transpose only the contents inside <b> tags
    final regex = RegExp(r'<b>(.*?)</b>');
    return html.replaceAllMapped(regex, (match) {
      final chordString = match.group(1) ?? '';
      final transposedChord = transposeChordString(chordString, semitones);
      return '<b>$transposedChord</b>';
    });
  }

  static String transposePlainText(String text, int semitones) {
    if (semitones == 0 || text.isEmpty) return text;

    final lines = text.split('\n');
    final strictChordRegex = RegExp(r'^([A-G][#b]?(m|min|maj|M|dim|aug|sus)?\d*(\/[A-G][#b]?)?)$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;

      final tokens = line.split(RegExp(r'\s+'));
      int strictChordCount = 0;
      int wordCount = 0;

      for (final token in tokens) {
        if (token.isEmpty) continue;
        final cleanToken = token.replaceAll(RegExp(r'^[(),]+|[(),]+$'), '');
        if (strictChordRegex.hasMatch(cleanToken)) {
          strictChordCount++;
        } else {
          wordCount++;
        }
      }

      // If a line is predominantly chords, format the chord tokens
      if (strictChordCount > 0 && wordCount <= (strictChordCount * 2)) {
        lines[i] = _transposeChordLine(line, semitones, strictChordRegex);
      }
    }
    return lines.join('\n');
  }

  static String _transposeChordLine(String line, int semitones, RegExp strictChordRegex) {
    return line.replaceAllMapped(RegExp(r'\S+'), (match) {
      final token = match.group(0)!;
      final cleanToken = token.replaceAll(RegExp(r'^[(),]+|[(),]+$'), '');
      
      if (strictChordRegex.hasMatch(cleanToken)) {
        return transposeChordString(token, semitones);
      }
      return token;
    });
  }

  static String transposeChordString(String chordString, int semitones) {
    // Match root notes, handling sharps and flats
    final noteRegex = RegExp(r'([A-G][#b]?)');
    return chordString.replaceAllMapped(noteRegex, (match) {
      final note = match.group(1)!;
      return transposeNote(note, semitones);
    });
  }

  static String transposeNote(String note, int semitones) {
    int index = _scale.indexOf(note);
    bool isFlat = false;
    
    if (index == -1) {
      index = _flatScale.indexOf(note);
      isFlat = true;
      if (index == -1) return note; // Not a recognized note
    }

    int newIndex = (index + semitones) % 12;
    if (newIndex < 0) {
      newIndex += 12;
    }
    
    // Attempt to maintain the sharp/flat paradigm but default to sharp
    return isFlat ? _flatScale[newIndex] : _scale[newIndex];
  }
}
