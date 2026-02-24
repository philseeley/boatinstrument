// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ais_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AISDisplaySettings _$AISDisplaySettingsFromJson(Map<String, dynamic> json) =>
    _AISDisplaySettings(
      recordSeconds: (json['recordSeconds'] as num?)?.toInt() ?? 10,
      recordPoints: (json['recordPoints'] as num?)?.toInt() ?? 1000,
      zoomIncrement: (json['zoomIncrement'] as num?)?.toDouble() ?? 0.5,
      signalkChart: json['signalkChart'] == null
          ? const SignalkChart()
          : SignalkChart.fromJson(json['signalkChart'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AISDisplaySettingsToJson(_AISDisplaySettings instance) =>
    <String, dynamic>{
      'recordSeconds': instance.recordSeconds,
      'recordPoints': instance.recordPoints,
      'zoomIncrement': instance.zoomIncrement,
      'signalkChart': instance.signalkChart.toJson(),
    };
