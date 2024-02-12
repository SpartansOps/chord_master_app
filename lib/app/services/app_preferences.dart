import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
  static const String prefChordList = 'prefChordList';
  static const String prefSettings = 'prefSettings';
}

class AppPreferences {
  final SharedPreferences _sharedPreferences;

  AppPreferences(this._sharedPreferences);

  Future<void> saveOneAsListOfMap(String key, Map<String, dynamic> value) async {
    List<String> list = _sharedPreferences.getStringList(key) ?? [];
    list.add(jsonEncode(value));
    await _sharedPreferences.setStringList(key, list);
  }

  Future<void> saveAsListOfMap(String key, List<Map<String, dynamic>> values) async {
    List<String> list = [];
    for (var map in values) {
      list.add(jsonEncode(map));
    }
    await _sharedPreferences.setStringList(key, list);
  }

  Future<List<Map<String, dynamic>>> getAsListOfMap(String key) async {
    List<String> list =  _sharedPreferences.getStringList(key) ?? [];
    List<Map<String, dynamic>> listOfMap = [];
    for (String s in list) {
      listOfMap.add(jsonDecode(s));
    }
    return listOfMap;
  }

  Future<void> saveAsMap(String key, Map<String, dynamic> value) async {
    await _sharedPreferences.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>> getAsMap(String key) async {
    String? map = _sharedPreferences.getString(key);
    if (map != null) {
      return jsonDecode(map);
    }
    return {};
  }
}