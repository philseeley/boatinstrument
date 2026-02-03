// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onvif_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ONVIFConfig _$ONVIFConfigFromJson(Map<String, dynamic> json) => ONVIFConfig(
  id: json['id'] as String? ?? '',
  url: json['url'] as String? ?? '',
  username: json['username'] as String? ?? '',
  password: json['password'] as String? ?? '',
);

Map<String, dynamic> _$ONVIFConfigToJson(ONVIFConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'username': instance.username,
      'password': instance.password,
    };

ONVIFSettings _$ONVIFSettingsFromJson(Map<String, dynamic> json) =>
    ONVIFSettings(
      configs:
          (json['configs'] as List<dynamic>?)
              ?.map((e) => ONVIFConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ONVIFSettingsToJson(ONVIFSettings instance) =>
    <String, dynamic>{
      'configs': instance.configs.map((e) => e.toJson()).toList(),
    };

ONVIFPerBoxSettings _$ONVIFPerBoxSettingsFromJson(Map<String, dynamic> json) =>
    ONVIFPerBoxSettings(
      id: json['id'] as String? ?? '',
      showTitle: json['showTitle'] as bool? ?? true,
      showControls: json['showControls'] as bool? ?? true,
      showHomeButton: json['showHomeButton'] as bool? ?? true,
    );

Map<String, dynamic> _$ONVIFPerBoxSettingsToJson(
  ONVIFPerBoxSettings instance,
) => <String, dynamic>{
  'id': instance.id,
  'showTitle': instance.showTitle,
  'showControls': instance.showControls,
  'showHomeButton': instance.showHomeButton,
};
