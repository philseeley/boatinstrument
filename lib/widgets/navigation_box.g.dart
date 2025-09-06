// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PositionSettings _$PositionSettingsFromJson(Map<String, dynamic> json) =>
    _PositionSettings(
      format:
          json['format'] as String? ?? '0{lat0d 0m.mmm c}\n{lon0d 0m.mmm c}',
    );

Map<String, dynamic> _$PositionSettingsToJson(_PositionSettings instance) =>
    <String, dynamic>{
      'format': instance.format,
    };
