// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wind_rose_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      type: $enumDecodeNullable(_$WindRoseTypeEnumMap, json['type']) ??
          WindRoseType.normal,
      showLabels: json['showLabels'] as bool? ?? true,
      showButton: json['showButton'] as bool? ?? false,
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'type': _$WindRoseTypeEnumMap[instance.type]!,
      'showLabels': instance.showLabels,
      'showButton': instance.showButton,
    };

const _$WindRoseTypeEnumMap = {
  WindRoseType.normal: 'normal',
  WindRoseType.closeHaul: 'closeHaul',
  WindRoseType.auto: 'auto',
};
