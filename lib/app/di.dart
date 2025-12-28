import 'package:chord_master_app/app/services/app_preferences.dart';
import 'package:chord_master_app/data/api/http_client.dart';
import 'package:chord_master_app/data/provider/chord_provider.dart';
import 'package:chord_master_app/data/repository/chord_repository.dart';
import 'package:chord_master_app/app/services/file_service.dart';
import 'package:chord_master_app/app/services/path_provider.dart';
import 'package:chord_master_app/app/services/permissions.dart';
import 'package:chord_master_app/presenter/pages/chord/chord_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/home/home_viewmodel.dart';
import 'package:chord_master_app/presenter/pages/settings/settings_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  final client =
      CustomHttp(baseUrl: const String.fromEnvironment("API_BASE_URL"));

  final prefs = await SharedPreferences.getInstance();
  instance.registerLazySingleton<CustomHttp>(() => client);
  instance
      .registerLazySingleton<ChordProvider>(() => ChordProvider(instance()));
  instance.registerLazySingleton<ChordRepository>(
      () => ChordRepository(instance()));
  instance
      .registerLazySingleton<PermissionService>(() => PermissionServiceImpl());
  instance.registerLazySingleton<PathProviderService>(
      () => PathProviderServiceImpl());
  instance
      .registerLazySingleton<ServiceFile>(() => ServiceFileImpl(instance()));
  instance.registerLazySingleton<AppPreferences>(() => AppPreferences(prefs));
  initSettingsModule();
}

void initHomeModule() {
  if (!GetIt.I.isRegistered<HomeViewModel>()) {
    instance.registerSingleton(
      HomeViewModel(
        instance(),
        instance(),
        instance(),
        instance(),
      ),
    );
  }
}

void initChordModule() {
  if (!GetIt.I.isRegistered<ChordViewModel>()) {
    instance.registerFactory(() => ChordViewModel());
  }
}

void initSettingsModule() {
  instance.registerSingleton(SettingsViewModel(instance()));
}
