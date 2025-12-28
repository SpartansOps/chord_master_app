import 'dart:convert';

import 'package:chord_master_app/data/mapper/chord_mapper.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/domain/chord.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
  static const String prefChordList = 'prefChordList';
  static const String prefDownloadList = 'prefDownloadList';
  static const String prefSettings = 'prefSettings';
}

class AppPreferences {
  final SharedPreferences _sharedPreferences;

  AppPreferences(this._sharedPreferences);

  Future<void> saveOneAsListOfMap(Map<String, dynamic> value) async {
    List<String> list =
        _sharedPreferences.getStringList(PrefKeys.prefChordList) ?? [];
    list.add(jsonEncode(value));
    await _sharedPreferences.setStringList(PrefKeys.prefChordList, list);
  }

  Future<void> saveAsListOfMap(List<Map<String, dynamic>> values) async {
    List<String> list = [];
    for (var map in values) {
      list.add(jsonEncode(map));
    }
    await _sharedPreferences.setStringList(PrefKeys.prefChordList, list);
  }

  Future<List<Map<String, dynamic>>> getAsListOfMap() async {
    List<String> list =
        _sharedPreferences.getStringList(PrefKeys.prefChordList) ?? [];
    List<Map<String, dynamic>> listOfMap = [];
    for (String s in list) {
      listOfMap.add(jsonDecode(s));
    }
    return listOfMap;
  }

  Future<void> saveDownloadListChords(List<Chord> values) async {
    List<String> list = [];
    for (var map in values) {
      list.add(
        jsonEncode(
          ChordData(
            id: map.id,
            chordNumber: map.chordNumber,
            chordName: map.chordName,
            chordContent: map.chordContent,
            sync: false,
            chordIntro: map.chordIntro,
            chordLink: map.chordLink,
          ).toJson(),
        ),
      );
    }
    await _sharedPreferences.setStringList(PrefKeys.prefDownloadList, list);
  }

  List<Chord> getDownloadListChords() {
    List<String> list =
        _sharedPreferences.getStringList(PrefKeys.prefDownloadList) ?? [];
    List<ChordData> listChord = [];
    for (String s in list) {
      listChord.add(ChordData.fromJson(jsonDecode(s)));
    }
    return listChord.map((e) => e.toDomain()).toList();
  }

  Future<void> saveAsMap(Map<String, dynamic> value) async {
    await _sharedPreferences.setString(
        PrefKeys.prefSettings, jsonEncode(value));
  }

  Future<Map<String, dynamic>> getAsMap() async {
    String? map = _sharedPreferences.getString(PrefKeys.prefSettings);
    if (map != null) {
      return jsonDecode(map);
    }
    return {};
  }
}
