import 'package:chord_master_app/data/api/api_end_points.dart';
import 'package:chord_master_app/data/api/http_client.dart';
import 'package:chord_master_app/data/api/http_error.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:dio/dio.dart';

class ChordProvider {
  final CustomHttpClient _client;

  ChordProvider(this._client);
  
  Future<List<ChordData>> getAllChords() async {
    try {
      final response = await _client.get(ApiEndPoints.getAllChords);

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: ResponseApi.getMessage(
            response.statusCode,
          ),
        );
      }
      List<ChordData> chords = [];
      for (var chord in response.data) {
        chords.add(ChordData.fromJson(chord));
      }
      return chords;
    } on DioException catch (e, stackTrace) {
      throw DioException(
        requestOptions: e.requestOptions,
        error: e.error,
        message: ResponseApi.getMessage(e.response?.statusCode),
        response: e.response,
        type: e.type,
        stackTrace: stackTrace,
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}