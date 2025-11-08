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
      showUTCButton: json['showUTCButton'] as bool? ?? false,
    );

Map<String, dynamic> _$DateTimePerBoxSettingsToJson(
        _DateTimePerBoxSettings instance) =>
    <String, dynamic>{
      'showDate': instance.showDate,
      'showTime': instance.showTime,
      'utc': instance.utc,
      'timeFormat': instance.timeFormat,
      'showUTCButton': instance.showUTCButton,
    };

_TimerDisplaySettings _$TimerDisplaySettingsFromJson(
        Map<String, dynamic> json) =>
    _TimerDisplaySettings(
      id: json['id'] as String? ?? '',
      notificationState: $enumDecodeNullable(
              _$NotificationStateEnumMap, json['notificationState']) ??
          NotificationState.warn,
      allowRestart: json['allowRestart'] as bool? ?? true,
      allowStop: json['allowStop'] as bool? ?? false,
    );

Map<String, dynamic> _$TimerDisplaySettingsToJson(
        _TimerDisplaySettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notificationState':
          _$NotificationStateEnumMap[instance.notificationState]!,
      'allowRestart': instance.allowRestart,
      'allowStop': instance.allowStop,
    };

const _$NotificationStateEnumMap = {
  NotificationState.normal: 'normal',
  NotificationState.nominal: 'nominal',
  NotificationState.alert: 'alert',
  NotificationState.warn: 'warn',
  NotificationState.alarm: 'alarm',
  NotificationState.emergency: 'emergency',
};

_Timer _$TimerFromJson(Map<String, dynamic> json) => _Timer(
      id: json['id'] as String? ?? '',
      time: json['time'] == null
          ? const TimeOfDay(hour: 0, minute: 0)
          : const TimeOfDayConverter().fromJson(json['time'] as String),
      delta: json['delta'] as bool? ?? false,
    );

Map<String, dynamic> _$TimerToJson(_Timer instance) => <String, dynamic>{
      'id': instance.id,
      'time': const TimeOfDayConverter().toJson(instance.time),
      'delta': instance.delta,
    };

_TimersSettings _$TimersSettingsFromJson(Map<String, dynamic> json) =>
    _TimersSettings(
      timers: (json['timers'] as List<dynamic>?)
              ?.map((e) => _Timer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TimersSettingsToJson(_TimersSettings instance) =>
    <String, dynamic>{
      'timers': instance.timers.map((e) => e.toJson()).toList(),
    };
