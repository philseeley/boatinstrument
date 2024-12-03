// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomSettings _$CustomSettingsFromJson(Map<String, dynamic> json) =>
    _CustomSettings(
      title: json['title'] as String? ?? 'title',
      path: json['path'] as String? ?? 'path',
      precision: (json['precision'] as num?)?.toInt() ?? 1,
      minLen: (json['minLen'] as num?)?.toInt() ?? 2,
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 100,
      angle: json['angle'] as bool? ?? false,
      smoothing: json['smoothing'] as bool? ?? true,
      units: json['units'] as String? ?? 'units',
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1,
      step: (json['step'] as num?)?.toDouble() ?? 1,
      portStarboard: json['portStarboard'] as bool? ?? false,
    );

Map<String, dynamic> _$CustomSettingsToJson(_CustomSettings instance) =>
    <String, dynamic>{
      'title': instance.title,
      'path': instance.path,
      'precision': instance.precision,
      'minLen': instance.minLen,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'angle': instance.angle,
      'smoothing': instance.smoothing,
      'units': instance.units,
      'multiplier': instance.multiplier,
      'step': instance.step,
      'portStarboard': instance.portStarboard,
    };

_DebugSettings _$DebugSettingsFromJson(Map<String, dynamic> json) =>
    _DebugSettings(
      path: json['path'] as String? ?? 'path',
    );

Map<String, dynamic> _$DebugSettingsToJson(_DebugSettings instance) =>
    <String, dynamic>{
      'path': instance.path,
    };
