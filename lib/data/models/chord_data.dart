import 'package:json_annotation/json_annotation.dart';
part 'chord_data.g.dart';

@JsonSerializable()
class ChordData {
  @JsonKey(name: "_id")
  String? id;
  int? chordNumber;
  String? chordName;
  String? chordIntro;
  String? chordContent;
  bool? sync;
  String? chordLink;

  ChordData({
    required this.id,
    required this.chordNumber,
    required this.chordName,
    this.chordIntro,
    required this.chordContent,
    required this.sync,
    this.chordLink,
  });

  factory ChordData.fromJson(Map<String, dynamic> data) => _$ChordDataFromJson(data);
  Map<String, dynamic> toJson() => _$ChordDataToJson(this);
}
