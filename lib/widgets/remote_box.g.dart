// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteControlSettings _$RemoteControlSettingsFromJson(
        Map<String, dynamic> json) =>
    _RemoteControlSettings(
      isGroup: json['isGroup'] as bool? ?? false,
      id: json['id'] as String? ?? '',
      controlPages: json['controlPages'] as bool? ?? true,
      controlRotatePages: json['controlRotatePages'] as bool? ?? true,
      controlBrightness: json['controlBrightness'] as bool? ?? true,
      enableLock: json['enableLock'] as bool? ?? false,
      lockSeconds: (json['lockSeconds'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$RemoteControlSettingsToJson(
        _RemoteControlSettings instance) =>
    <String, dynamic>{
      'isGroup': instance.isGroup,
      'id': instance.id,
      'controlPages': instance.controlPages,
      'controlRotatePages': instance.controlRotatePages,
      'controlBrightness': instance.controlBrightness,
      'enableLock': instance.enableLock,
      'lockSeconds': instance.lockSeconds,
    };
