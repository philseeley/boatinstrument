// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PositionSettings _$PositionSettingsFromJson(Map<String, dynamic> json) =>
    _PositionSettings(
      latFormat: json['latFormat'] as String? ?? '0{lat0d 0m.mmm c}',
      lonFormat: json['lonFormat'] as String? ?? '{lon0d 0m.mmm c}',
    );

Map<String, dynamic> _$PositionSettingsToJson(_PositionSettings instance) =>
    <String, dynamic>{
      'latFormat': instance.latFormat,
      'lonFormat': instance.lonFormat,
    };
