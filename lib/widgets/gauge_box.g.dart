// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gauge_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GraphSettings _$GraphSettingsFromJson(Map<String, dynamic> json) =>
    _GraphSettings(
      displayDuration: $enumDecodeNullable(
              _$GraphDurationEnumMap, json['displayDuration']) ??
          GraphDuration.fifteenMinutes,
    );

Map<String, dynamic> _$GraphSettingsToJson(_GraphSettings instance) =>
    <String, dynamic>{
      'displayDuration': _$GraphDurationEnumMap[instance.displayDuration]!,
    };

const _$GraphDurationEnumMap = {
  GraphDuration.oneMinutes: 'oneMinutes',
  GraphDuration.twoMinutes: 'twoMinutes',
  GraphDuration.threeMinutes: 'threeMinutes',
  GraphDuration.fourMinutes: 'fourMinutes',
  GraphDuration.fiveMinutes: 'fiveMinutes',
  GraphDuration.tenMinutes: 'tenMinutes',
  GraphDuration.fifteenMinutes: 'fifteenMinutes',
  GraphDuration.thirtyMinutes: 'thirtyMinutes',
  GraphDuration.oneHour: 'oneHour',
  GraphDuration.twoHours: 'twoHours',
  GraphDuration.fourHours: 'fourHours',
  GraphDuration.sixHours: 'sixHours',
  GraphDuration.twelveHours: 'twelveHours',
  GraphDuration.oneDay: 'oneDay',
};
