class Settings {
  bool darkMode;

  Settings({this.darkMode = false});

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkMode: map['darkMode'],
    );
  }

  factory Settings.empty() {
    return Settings(darkMode: false);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['darkMode'] = darkMode;
    return data;
  }
}