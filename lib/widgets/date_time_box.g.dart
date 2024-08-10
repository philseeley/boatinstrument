// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_time_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DateTimeSettings _$DateTimeSettingsFromJson(Map<String, dynamic> json) =>
    _DateTimeSettings(
      dateFormat: json['dateFormat'] as String? ?? 'yyyy-MM-dd',
    );

Map<String, dynamic> _$DateTimeSettingsToJson(_DateTimeSettings instance) =>
    <String, dynamic>{
      'dateFormat': instance.dateFormat,
    };

_DateTimePerBoxSettings _$DateTimePerBoxSettingsFromJson(
        Map<String, dynamic> json) =>
    _DateTimePerBoxSettings(
      showDate: json['showDate'] as bool? ?? true,
      showTime: json['showTime'] as bool? ?? true,
      utc: json['utc'] as bool? ?? false,
      timeFormat: json['timeFormat'] as String? ?? 'HH:mm:ss',
    );

Map<String, dynamic> _$DateTimePerBoxSettingsToJson(
        _DateTimePerBoxSettings instance) =>
    <String, dynamic>{
      'showDate': instance.showDate,
      'showTime': instance.showTime,
      'utc': instance.utc,
      'timeFormat': instance.timeFormat,
    };
