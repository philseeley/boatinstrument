// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autopilot_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutopilotControlPerBoxSettings _$AutopilotControlPerBoxSettingsFromJson(
        Map<String, dynamic> json) =>
    _AutopilotControlPerBoxSettings(
      enableLock: json['enableLock'] as bool? ?? true,
      lockSeconds: (json['lockSeconds'] as num?)?.toInt() ?? 5,
      showLabels: json['showLabels'] as bool? ?? true,
    );

Map<String, dynamic> _$AutopilotControlPerBoxSettingsToJson(
        _AutopilotControlPerBoxSettings instance) =>
    <String, dynamic>{
      'enableLock': instance.enableLock,
      'lockSeconds': instance.lockSeconds,
      'showLabels': instance.showLabels,
    };
