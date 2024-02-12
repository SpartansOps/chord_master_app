import 'dart:async';
import 'package:chord_master_app/app/services/app_preferences.dart';
import 'package:chord_master_app/domain/settings.dart';
import 'package:chord_master_app/presenter/base/base_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class SettingsViewModel extends BaseViewModel {
  final AppPreferences _preferences;
  Settings settings = Settings.empty();
  SettingsViewModel(this._preferences) {
    init();
  }

  final StreamController<Settings> _settingsController = BehaviorSubject<Settings>();
  Stream<Settings> get settingsStream => _settingsController.stream;

  Future<void> init() async {
    Map<String, dynamic> settingsMap = await _preferences.getAsMap(PrefKeys.prefSettings);
    if (settingsMap.isEmpty) return;
    settings = Settings.fromMap(settingsMap);
    _settingsController.sink.add(settings);
  }

  Future<void> setDarkMode(bool value) async {
    settings.darkMode = value;
    await _preferences.saveAsMap(PrefKeys.prefSettings, settings.toMap());
    _settingsController.sink.add(settings);
  }

  @override
  void dispose() {
    _settingsController.close();
    super.dispose();
  }
}
