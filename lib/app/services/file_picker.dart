import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

abstract interface class FilePickerService {
  Future<File?> pickFile();
  Future<List<Map<String, dynamic>>> convertFileToMap(File file);
}

class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    return File(result?.files.single.path ?? "");
  }

  @override
  Future<List<Map<String, dynamic>>> convertFileToMap(File file) async {
    if (!await file.exists()) return [];
    final contents = await file.readAsString();
    final fileMap = jsonDecode(contents);
    List<Map<String, dynamic>> maps = [];
    for (Map<String, dynamic> map in fileMap) {
      maps.add(map);
    }
    return maps;
  }
}