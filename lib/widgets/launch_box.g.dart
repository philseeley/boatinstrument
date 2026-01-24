// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LaunchConfig _$LaunchConfigFromJson(Map<String, dynamic> json) =>
    _LaunchConfig(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['icon'] as String? ?? '',
      executable: json['executable'] as String? ?? '',
      params: json['params'] as String? ?? '',
    );

Map<String, dynamic> _$LaunchConfigToJson(_LaunchConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'icon': instance.image,
      'executable': instance.executable,
      'params': instance.params,
    };

_LaunchSettings _$LaunchSettingsFromJson(Map<String, dynamic> json) =>
    _LaunchSettings(
      configs:
          (json['configs'] as List<dynamic>?)
              ?.map((e) => _LaunchConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LaunchSettingsToJson(_LaunchSettings instance) =>
    <String, dynamic>{
      'configs': instance.configs.map((e) => e.toJson()).toList(),
    };

_LaunchPerBoxSettings _$LaunchPerBoxSettingsFromJson(
  Map<String, dynamic> json,
) => _LaunchPerBoxSettings(id: json['id'] as String? ?? '');

Map<String, dynamic> _$LaunchPerBoxSettingsToJson(
  _LaunchPerBoxSettings instance,
) => <String, dynamic>{'id': instance.id};
