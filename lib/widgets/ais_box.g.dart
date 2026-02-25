// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ais_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AISDisplaySettings _$AISDisplaySettingsFromJson(Map<String, dynamic> json) =>
    _AISDisplaySettings(
      showNames: json['showNames'] as bool? ?? true,
      predictionMinutes: (json['predictionMinutes'] as num?)?.toDouble() ?? 5,
      vesselTimeout: (json['vesselTimeout'] as num?)?.toInt() ?? 10,
      signalkChart: json['signalkChart'] == null
          ? const SignalkChart()
          : SignalkChart.fromJson(json['signalkChart'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AISDisplaySettingsToJson(_AISDisplaySettings instance) =>
    <String, dynamic>{
      'showNames': instance.showNames,
      'predictionMinutes': instance.predictionMinutes,
      'vesselTimeout': instance.vesselTimeout,
      'signalkChart': instance.signalkChart.toJson(),
    };
