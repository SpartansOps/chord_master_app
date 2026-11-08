import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chord_master_app/data/api/api_end_points.dart';
import 'package:chord_master_app/data/api/http_client.dart';
import 'package:chord_master_app/data/api/http_error.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:http/http.dart';

class ChordApi {
  final CustomHttp _client;

  ChordApi(this._client);

  static const _jsonHeaders = {"content-type": "application/json"};

  Future<ChordData?> saveChord(ChordData chord) async {
    final isUpdate = chord.id != null;

    final response = await _send(() => isUpdate
        ? _client.put(ApiEndPoints.updateChord,
            body: jsonEncode(chord.toJson()), headers: _jsonHeaders)
        : _client.post(ApiEndPoints.saveChord,
            body: jsonEncode(chord.removeNulls()), headers: _jsonHeaders));

    final expectedStatus = isUpdate ? HttpStatus.ok : HttpStatus.created;
    if (response.statusCode != expectedStatus) {
      throw ClientException(ResponseApi.getMessage(response.statusCode));
    }

    return ChordData.fromJson(jsonDecode(response.body));
  }

  Future<List<ChordData>> getAllChords() async {
    final response = await _send(
        () => _client.get(ApiEndPoints.getAllChords, headers: _jsonHeaders));

    if (response.statusCode != HttpStatus.ok) {
      throw ClientException(ResponseApi.getMessage(response.statusCode));
    }

    try {
      return [
        for (final chord in jsonDecode(response.body)) ChordData.fromJson(chord)
      ];
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  /// Falha de rede (sem resposta do servidor) vira mensagem genérica amigável.
  Future<Response> _send(Future<Response> Function() request) async {
    try {
      return await request();
    } on ClientException {
      throw ClientException(ResponseApi.getMessage(null));
    }
  }
}
