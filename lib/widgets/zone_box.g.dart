// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Zone _$ZoneFromJson(Map<String, dynamic> json) => _Zone(
  lower: (json['lower'] as num?)?.toDouble(),
  upper: (json['upper'] as num?)?.toDouble(),
  state:
      $enumDecodeNullable(_$NotificationStateEnumMap, json['state']) ??
      NotificationState.normal,
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$ZoneToJson(_Zone instance) => <String, dynamic>{
  'lower': instance.lower,
  'upper': instance.upper,
  'state': _$NotificationStateEnumMap[instance.state]!,
  'message': instance.message,
};

const _$NotificationStateEnumMap = {
  NotificationState.normal: 'normal',
  NotificationState.nominal: 'nominal',
  NotificationState.alert: 'alert',
  NotificationState.warn: 'warn',
  NotificationState.alarm: 'alarm',
  NotificationState.emergency: 'emergency',
};

_Meta _$MetaFromJson(Map<String, dynamic> json) => _Meta(
  zones:
      (json['zones'] as List<dynamic>?)
          ?.map((e) => _Zone.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MetaToJson(_Meta instance) => <String, dynamic>{
  'zones': instance.zones.map((e) => e.toJson()).toList(),
};

_Alert _$AlertFromJson(Map<String, dynamic> json) => _Alert(
  type: $enumDecodeNullable(_$AlertTypeEnumMap, json['type']) ?? AlertType.aws,
  meta: json['meta'] == null
      ? null
      : _Meta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AlertToJson(_Alert instance) => <String, dynamic>{
  'type': _$AlertTypeEnumMap[instance.type]!,
  'meta': instance.meta.toJson(),
};

const _$AlertTypeEnumMap = {
  AlertType.aws: 'aws',
  AlertType.dbs: 'dbs',
  AlertType.test: 'test',
  AlertType.dbk: 'dbk',
};

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => _Alert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  normalAlert: json['normalAlert'] as bool? ?? false,
  alertAlert: json['alertAlert'] as bool? ?? true,
  warnAlert: json['warnAlert'] as bool? ?? true,
  alarmAlert: json['alarmAlert'] as bool? ?? true,
  emergencyAlert: json['emergencyAlert'] as bool? ?? true,
);

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
  'alerts': instance.alerts.map((e) => e.toJson()).toList(),
  'normalAlert': instance.normalAlert,
  'alertAlert': instance.alertAlert,
  'warnAlert': instance.warnAlert,
  'alarmAlert': instance.alarmAlert,
  'emergencyAlert': instance.emergencyAlert,
};
