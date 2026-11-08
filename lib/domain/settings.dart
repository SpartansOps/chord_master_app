class Settings {
  final bool darkMode;
  final double readerFontSize;
  final double readerMargin;

  const Settings({
    this.darkMode = true,
    this.readerFontSize = 16,
    this.readerMargin = 8,
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkMode: map['darkMode'] as bool? ?? true,
      readerFontSize: (map['readerFontSize'] as num?)?.toDouble() ?? 16,
      readerMargin: (map['readerMargin'] as num?)?.toDouble() ?? 8,
    );
  }

  Settings copyWith({bool? darkMode, double? readerFontSize, double? readerMargin}) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
      readerFontSize: readerFontSize ?? this.readerFontSize,
      readerMargin: readerMargin ?? this.readerMargin,
    );
  }

  Map<String, dynamic> toMap() => {
        'darkMode': darkMode,
        'readerFontSize': readerFontSize,
        'readerMargin': readerMargin,
      };
}
