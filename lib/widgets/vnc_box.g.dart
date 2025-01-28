// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vnc_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VNCSettings _$VNCSettingsFromJson(Map<String, dynamic> json) => _VNCSettings(
      host: json['host'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 5900,
      password: json['password'] as String? ?? '',
    );

Map<String, dynamic> _$VNCSettingsToJson(_VNCSettings instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'password': instance.password,
    };
