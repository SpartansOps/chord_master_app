import 'package:chord_master_app/app/services/admin_auth.dart';
import 'package:chord_master_app/app/services/app_preferences.dart';
import 'package:chord_master_app/data/api/chord_api.dart';
import 'package:chord_master_app/data/api/cifra_club_scraper.dart';
import 'package:chord_master_app/data/api/http_client.dart';
import 'package:chord_master_app/data/repository/chord_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Infraestrutura. O SharedPreferences é criado no main() e injetado via override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Sobrescreva sharedPreferencesProvider no ProviderScope'),
);

final appPreferencesProvider =
    Provider<AppPreferences>((ref) => AppPreferences(ref.watch(sharedPreferencesProvider)));

final httpClientProvider = Provider<CustomHttp>(
  (ref) => CustomHttp(baseUrl: const String.fromEnvironment('API_BASE_URL')),
);

final chordApiProvider = Provider<ChordApi>((ref) => ChordApi(ref.watch(httpClientProvider)));

final chordRepositoryProvider =
    Provider<ChordRepository>((ref) => ChordRepository(ref.watch(chordApiProvider)));

final cifraClubScraperProvider = Provider<CifraClubScraper>((ref) => CifraClubScraper());

final adminAuthProvider = Provider<AdminAuth>((ref) => AdminAuth());
