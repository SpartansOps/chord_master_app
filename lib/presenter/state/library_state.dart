import 'package:chord_master_app/app/providers.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

/// Biblioteca: todas as cifras da API, com cópia local para uso offline.
final libraryProvider = NotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);

class LibraryState {
  const LibraryState({this.chords = const [], this.syncing = false});

  final List<Chord> chords;
  final bool syncing;

  LibraryState copyWith({List<Chord>? chords, bool? syncing}) =>
      LibraryState(chords: chords ?? this.chords, syncing: syncing ?? this.syncing);
}

typedef SyncResult = ({bool ok, String message});

class LibraryNotifier extends Notifier<LibraryState> {
  @override
  LibraryState build() => LibraryState(chords: ref.read(appPreferencesProvider).getLibrary());

  /// Baixa as cifras da API. Sem internet, mantém a cópia local.
  Future<SyncResult> sync() async {
    if (state.syncing) return (ok: false, message: 'Sincronização em andamento');
    state = state.copyWith(syncing: true);
    try {
      final connection = await Connectivity().checkConnectivity();
      final online = connection.any((r) => r != ConnectivityResult.none);
      if (!online) {
        return (ok: false, message: 'Sem conexão. Mostrando as cifras salvas.');
      }

      final chords = await ref.read(chordRepositoryProvider).getAllChords();
      if (chords.isEmpty) {
        return (ok: false, message: 'Nenhuma cifra encontrada no servidor.');
      }
      await ref.read(appPreferencesProvider).saveLibrary(chords);
      state = state.copyWith(chords: chords);
      return (ok: true, message: '${chords.length} cifras sincronizadas');
    } on ClientException catch (e) {
      return (ok: false, message: e.message);
    } catch (_) {
      return (ok: false, message: 'Não foi possível sincronizar. Tente novamente.');
    } finally {
      state = state.copyWith(syncing: false);
    }
  }

  /// Insere ou atualiza uma cifra (após salvar na API).
  Future<void> upsert(Chord chord) async {
    final list = [...state.chords];
    final index = list.indexWhere((c) => c.id != null && c.id == chord.id);
    if (index >= 0) {
      list[index] = chord;
    } else {
      list.add(chord);
    }
    state = state.copyWith(chords: list);
    await ref.read(appPreferencesProvider).saveLibrary(list);
  }
}

Chord? findChordById(List<Chord> chords, String id) {
  for (final chord in chords) {
    if (chord.id == id) return chord;
  }
  return null;
}

/// Texto da busca na biblioteca.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

/// Biblioteca filtrada por nome ou número (ignora acentos e maiúsculas).
final filteredLibraryProvider = Provider<List<Chord>>((ref) {
  final chords = ref.watch(libraryProvider.select((s) => s.chords));
  final query = _normalize(ref.watch(searchQueryProvider).trim());
  if (query.isEmpty) return chords;
  return chords
      .where((c) =>
          _normalize(c.chordName ?? '').contains(query) ||
          (c.chordNumber?.toString() ?? '').contains(query))
      .toList();
});

String _normalize(String value) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString();
}
