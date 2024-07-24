// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_time_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      dateFormat: json['dateFormat'] as String? ?? 'yyyy-MM-dd',
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'dateFormat': instance.dateFormat,
    };

_PerBoxSettings _$PerBoxSettingsFromJson(Map<String, dynamic> json) =>
    _PerBoxSettings(
      showDate: json['showDate'] as bool? ?? true,
      showTime: json['showTime'] as bool? ?? true,
      utc: json['utc'] as bool? ?? false,
      timeFormat: json['timeFormat'] as String? ?? 'HH:mm:ss',
    );

Map<String, dynamic> _$PerBoxSettingsToJson(_PerBoxSettings instance) =>
    <String, dynamic>{
      'showDate': instance.showDate,
      'showTime': instance.showTime,
      'utc': instance.utc,
      'timeFormat': instance.timeFormat,
    };
