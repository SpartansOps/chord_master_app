import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chord_master_app/data/api/api_end_points.dart';
import 'package:chord_master_app/data/api/http_client.dart';
import 'package:chord_master_app/data/api/http_error.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:http/http.dart';

class ChordProvider {
  final CustomHttp _client;

  ChordProvider(this._client);

  Future<ChordData?> saveChord(ChordData chord) async {
    int statusCode = -1;
    try {
      Response? response;

      if (chord.id != null) {
        response = await _client.put(ApiEndPoints.updateChord,
            body: jsonEncode(chord.toJson()),
            headers: {
              "content-type": "application/json",
            });

        if (response.statusCode != HttpStatus.ok) {
          throw throw ClientException(
              ResponseApi.getMessage(response.statusCode));
        }
      } else {
        response = await _client.post(ApiEndPoints.saveChord,
            body: jsonEncode(chord.removeNulls()),
            headers: {
              "content-type": "application/json",
            });

        if (response.statusCode != HttpStatus.created) {
          throw throw ClientException(
              ResponseApi.getMessage(response.statusCode));
        }
      }

      return ChordData.fromJson(jsonDecode(response.body));
    } on ClientException {
      throw throw ClientException(ResponseApi.getMessage(statusCode));
    }
  }

  Future<List<ChordData>> getAllChords() async {
    int statusCode = -1;
    try {
      final response = await _client.get(
        ApiEndPoints.getAllChords,
        headers: {
          "content-type": "application/json",
        },
      );

      statusCode = response.statusCode;
      if (response.statusCode != HttpStatus.ok) {
        throw throw ClientException(
            ResponseApi.getMessage(response.statusCode));
      }
      List<ChordData> chords = [];
      for (var chord in jsonDecode(response.body)) {
        chords.add(ChordData.fromJson(chord));
      }
      return chords;
    } on ClientException {
      throw ClientException(ResponseApi.getMessage(statusCode));
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
