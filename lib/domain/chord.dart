class Chord {
  String? id;
  int? chordNumber;
  String? chordName;
  String? chordIntro;
  String? chordContent;
  bool? sync;
  String? chordLink;

  Chord({
    this.id,
    this.chordNumber,
    this.chordName,
    this.chordIntro,
    this.chordContent,
    this.sync,
    this.chordLink,
  });

  Chord copyWith({
    String? id,
    int? chordNumber,
    String? chordName,
    String? chordIntro,
    String? chordContent,
    bool? sync,
    String? chordLink,
  }) {
    return Chord(
      id: id ?? this.id,
      chordNumber: chordNumber ?? this.chordNumber,
      chordName: chordName ?? this.chordName,
      chordIntro: chordIntro ?? this.chordIntro,
      chordContent: chordContent ?? this.chordContent,
      chordLink: chordLink ?? this.chordLink,
    );
  }

  factory Chord.empty() {
    return Chord(
      id: null,
      chordNumber: null,
      chordName: '',
      chordIntro: '',
      chordContent: '',
      chordLink: '',
    );
  }
}
