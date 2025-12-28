// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chord_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChordData _$ChordDataFromJson(Map<String, dynamic> json) => ChordData(
      id: json['_id'] as String?,
      chordNumber: json['chordNumber'] as int?,
      chordName: json['chordName'] as String?,
      chordIntro: json['chordIntro'] as String?,
      chordContent: json['chordContent'] as String?,
      sync: json['sync'] as bool?,
      chordLink: json['chordLink'] as String?,
    );

Map<String, dynamic> _$ChordDataToJson(ChordData instance) => <String, dynamic>{
      '_id': instance.id,
      'chordNumber': instance.chordNumber,
      'chordName': instance.chordName,
      'chordIntro': instance.chordIntro,
      'chordContent': instance.chordContent,
      'sync': instance.sync,
      'chordLink': instance.chordLink,
    };
