// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_time_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      showDate: json['showDate'] as bool? ?? true,
      showTime: json['showTime'] as bool? ?? true,
      utc: json['utc'] as bool? ?? false,
      dateFormat: json['dateFormat'] as String? ?? 'yyyy-MM-dd',
      timeFormat: json['timeFormat'] as String? ?? 'HH:mm:ss',
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'showDate': instance.showDate,
      'showTime': instance.showTime,
      'utc': instance.utc,
      'dateFormat': instance.dateFormat,
      'timeFormat': instance.timeFormat,
    };
