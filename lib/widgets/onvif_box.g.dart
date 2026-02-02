// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onvif_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ONVIFConfig _$ONVIFConfigFromJson(Map<String, dynamic> json) => _ONVIFConfig(
  id: json['id'] as String? ?? '',
  url: json['url'] as String? ?? '',
  username: json['username'] as String? ?? '',
  password: json['password'] as String? ?? '',
);

Map<String, dynamic> _$ONVIFConfigToJson(_ONVIFConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'username': instance.username,
      'password': instance.password,
    };

_ONVIFSettings _$ONVIFSettingsFromJson(Map<String, dynamic> json) =>
    _ONVIFSettings(
      configs:
          (json['configs'] as List<dynamic>?)
              ?.map((e) => _ONVIFConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ONVIFSettingsToJson(_ONVIFSettings instance) =>
    <String, dynamic>{
      'configs': instance.configs.map((e) => e.toJson()).toList(),
    };

_ONVIFPerBoxSettings _$ONVIFPerBoxSettingsFromJson(Map<String, dynamic> json) =>
    _ONVIFPerBoxSettings(id: json['id'] as String? ?? '');

Map<String, dynamic> _$ONVIFPerBoxSettingsToJson(
  _ONVIFPerBoxSettings instance,
) => <String, dynamic>{'id': instance.id};
