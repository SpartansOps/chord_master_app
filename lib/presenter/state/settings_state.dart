import 'package:chord_master_app/app/providers.dart';
import 'package:chord_master_app/domain/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<Settings> {
  static const minFontSize = 10.0;
  static const maxFontSize = 40.0;
  static const maxMargin = 48.0;
  static const marginStep = 4.0;

  @override
  Settings build() {
    final map = ref.read(appPreferencesProvider).getSettings();
    return map.isEmpty ? const Settings() : Settings.fromMap(map);
  }

  void toggleDarkMode() => _update(state.copyWith(darkMode: !state.darkMode));

  void changeFontSize(double delta) => _update(state.copyWith(
        readerFontSize: (state.readerFontSize + delta).clamp(minFontSize, maxFontSize),
      ));

  void changeMargin(double delta) => _update(state.copyWith(
        readerMargin: (state.readerMargin + delta).clamp(0, maxMargin),
      ));

  void _update(Settings value) {
    state = value;
    ref.read(appPreferencesProvider).saveSettings(value.toMap());
  }
}
