// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'double_value_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      title: json['title'] as String? ?? 'title',
      path: json['path'] as String? ?? 'path',
      precision: (json['precision'] as num?)?.toInt() ?? 1,
      minLen: (json['minLen'] as num?)?.toInt() ?? 2,
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 100,
      angle: json['angle'] as bool? ?? false,
      units: json['units'] as String? ?? 'units',
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'title': instance.title,
      'path': instance.path,
      'precision': instance.precision,
      'minLen': instance.minLen,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'angle': instance.angle,
      'units': instance.units,
      'multiplier': instance.multiplier,
    };
