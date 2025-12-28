import 'dart:convert';
import 'dart:io';

import 'package:chord_master_app/app/constants.dart';
import 'package:chord_master_app/app/services/path_provider.dart';
import 'package:flutter/services.dart';

abstract class ServiceFile {
  Future<void> writeListOfMap(List<Map<String, dynamic>> data);
  Future<List<Map<String, dynamic>>> readAsListOfMap();
  Future<List<Map<String, dynamic>>> readFromAssetsAsListOfMap();
}

class ServiceFileImpl extends ServiceFile {
  final PathProviderService pathProviderService;

  Future<File> get _localPathFile async {
    final path = await pathProviderService.getDocumentsAppPath;
    return File('$path/${Constants.musicPath}');
  }

  ServiceFileImpl(this.pathProviderService);

  @override
  Future<List<Map<String, dynamic>>> readAsListOfMap() async {
    final file = await _localPathFile;
    if (!await file.exists()) return [];
    final contents = await file.readAsString();
    final fileMap = jsonDecode(contents);
    List<Map<String, dynamic>> maps = [];
    for (Map<String, dynamic> map in fileMap) {
      maps.add(map);
    }
    return maps;
  }

  @override
  Future<void> writeListOfMap(List<Map<String, dynamic>> data) async {
    final file = await _localPathFile;
    await file.writeAsString(jsonEncode(data));
  }
  
  @override
  Future<List<Map<String, dynamic>>> readFromAssetsAsListOfMap() async {
    String content = await rootBundle.loadString(Constants.assetsPathJsonData);
    List<dynamic> dataList = jsonDecode(content);
    List<Map<String, dynamic>> data = [];
    for (var map in dataList) {
      data.add(map);
    }
    return data;
  }
}
