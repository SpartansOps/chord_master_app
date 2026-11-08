import 'package:chord_master_app/app/providers.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repertório: a lista de músicas do culto, na ordem em que serão tocadas.
/// Cada item é uma cópia (pode estar transposta) e fica só no aparelho.
final setlistProvider = NotifierProvider<SetlistNotifier, List<Chord>>(SetlistNotifier.new);

class SetlistNotifier extends Notifier<List<Chord>> {
  @override
  List<Chord> build() => ref.read(appPreferencesProvider).getSetlist();

  void add(Chord chord) => _save([...state, chord]);

  void replaceAt(int index, Chord chord) {
    if (index < 0 || index >= state.length) return;
    _save([...state]..[index] = chord);
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    _save([...state]..removeAt(index));
  }

  void insertAt(int index, Chord chord) {
    _save([...state]..insert(index.clamp(0, state.length), chord));
  }

  /// Índices já ajustados (como entrega o `onReorderItem`).
  void move(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _save(list);
  }

  void clear() => _save([]);

  void _save(List<Chord> list) {
    state = list;
    ref.read(appPreferencesProvider).saveSetlist(list);
  }
}
