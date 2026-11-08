import 'dart:convert';

import 'package:chord_master_app/data/mapper/chord_mapper.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
  // Mantidas iguais às versões anteriores para não perder dados salvos.
  static const String setlist = 'prefChordList';
  static const String library = 'prefDownloadList';
  static const String settings = 'prefSettings';
  static const String draft = 'prefChordDraft';
}

/// Armazenamento local (localStorage na web).
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  // Biblioteca (cifras baixadas da API)
  List<Chord> getLibrary() => _readChords(PrefKeys.library);

  Future<void> saveLibrary(List<Chord> chords) => _writeChords(
        PrefKeys.library,
        chords.map((c) => c.copyWith(sync: false)).toList(),
      );

  // Repertório (lista do culto)
  List<Chord> getSetlist() => _readChords(PrefKeys.setlist);

  Future<void> saveSetlist(List<Chord> chords) => _writeChords(PrefKeys.setlist, chords);

  // Configurações
  Map<String, dynamic> getSettings() {
    final raw = _prefs.getString(PrefKeys.settings);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSettings(Map<String, dynamic> value) =>
      _prefs.setString(PrefKeys.settings, jsonEncode(value));

  // Rascunho da cifra nova
  Chord? getDraft() {
    final raw = _prefs.getString(PrefKeys.draft);
    if (raw == null) return null;
    return ChordData.fromJson(jsonDecode(raw)).toDomain();
  }

  Future<void> saveDraft(Chord chord) =>
      _prefs.setString(PrefKeys.draft, jsonEncode(chord.toData().toJson()));

  Future<void> clearDraft() => _prefs.remove(PrefKeys.draft);

  List<Chord> _readChords(String key) {
    final list = _prefs.getStringList(key) ?? [];
    return list.map((s) => ChordData.fromJson(jsonDecode(s)).toDomain()).toList();
  }

  Future<void> _writeChords(String key, List<Chord> chords) => _prefs.setStringList(
        key,
        chords.map((c) => jsonEncode(c.toData().toJson())).toList(),
      );
}
