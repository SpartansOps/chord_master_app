import 'package:chord_master_app/data/mapper/chord_mapper.dart';
import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/data/provider/chord_provider.dart';
import 'package:chord_master_app/domain/chord.dart';

class ChordRepository {
  final ChordProvider _provider;

  ChordRepository(this._provider);

  Future<List<Chord>> getAllChords() async {
    List<ChordData> data = await _provider.getAllChords();
    return data.map((e) => e.toDomain()).toList();    
  }
}
