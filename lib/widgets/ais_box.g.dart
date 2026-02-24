// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ais_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AISDisplaySettings _$AISDisplaySettingsFromJson(Map<String, dynamic> json) =>
    _AISDisplaySettings(
      showNames: json['showNames'] as bool? ?? true,
      minutes: (json['minutes'] as num?)?.toDouble() ?? 5,
      signalkChart: json['signalkChart'] == null
          ? const SignalkChart()
          : SignalkChart.fromJson(json['signalkChart'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AISDisplaySettingsToJson(_AISDisplaySettings instance) =>
    <String, dynamic>{
      'showNames': instance.showNames,
      'minutes': instance.minutes,
      'signalkChart': instance.signalkChart.toJson(),
    };
