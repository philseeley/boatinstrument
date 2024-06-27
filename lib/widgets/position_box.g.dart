// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      latFormat: json['latFormat'] as String? ?? '0{lat0d 0m.mmm c}',
      lonFormat: json['lonFormat'] as String? ?? '{lon0d 0m.mmm c}',
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'latFormat': instance.latFormat,
      'lonFormat': instance.lonFormat,
    };
