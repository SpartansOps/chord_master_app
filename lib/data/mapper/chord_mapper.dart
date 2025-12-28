import 'package:chord_master_app/data/models/chord_data.dart';
import 'package:chord_master_app/domain/chord.dart';

extension ChordDataMapper on ChordData {
  Chord toDomain() {
    return Chord(
      id: id,
      chordNumber: chordNumber,
      chordName: chordName,
      chordContent: chordContent,
      sync: sync,
      chordIntro: chordIntro,
      chordLink: chordLink,
    );
  }
}
