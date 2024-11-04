// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'propulsion_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EngineSettings _$EngineSettingsFromJson(Map<String, dynamic> json) =>
    _EngineSettings(
      id: json['id'] as String? ?? '',
      maxRPM: (json['maxRPM'] as num?)?.toInt() ?? 5000,
      redLine: (json['redLine'] as num?)?.toInt() ?? 3500,
    );

Map<String, dynamic> _$EngineSettingsToJson(_EngineSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maxRPM': instance.maxRPM,
      'redLine': instance.redLine,
    };
