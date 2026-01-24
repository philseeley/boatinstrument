// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CelestialSettings _$CelestialSettingsFromJson(Map<String, dynamic> json) =>
    _CelestialSettings(timeFormat: json['timeFormat'] as String? ?? 'HH:mm');

Map<String, dynamic> _$CelestialSettingsToJson(_CelestialSettings instance) =>
    <String, dynamic>{'timeFormat': instance.timeFormat};

_MoonPerBoxSettings _$MoonPerBoxSettingsFromJson(Map<String, dynamic> json) =>
    _MoonPerBoxSettings(showMoon: json['showMoon'] as bool? ?? true);

Map<String, dynamic> _$MoonPerBoxSettingsToJson(_MoonPerBoxSettings instance) =>
    <String, dynamic>{'showMoon': instance.showMoon};
