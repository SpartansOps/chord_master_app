import 'package:chord_master_app/data/api/chord_api.dart';
import 'package:chord_master_app/data/mapper/chord_mapper.dart';
import 'package:chord_master_app/domain/chord.dart';

class ChordRepository {
  final ChordApi _api;

  ChordRepository(this._api);

  Future<Chord?> saveChord(Chord chord) async {
    final data = await _api.saveChord(chord.toData());
    return data?.toDomain();
  }

  Future<List<Chord>> getAllChords() async {
    final data = await _api.getAllChords();
    return data.map((e) => e.toDomain()).toList();
  }
}
