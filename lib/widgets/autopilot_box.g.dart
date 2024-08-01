// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autopilot_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutopilotControlSettings _$AutopilotControlSettingsFromJson(
        Map<String, dynamic> json) =>
    _AutopilotControlSettings(
      clientID: json['clientID'],
      authToken: json['authToken'] as String? ?? '',
    );

Map<String, dynamic> _$AutopilotControlSettingsToJson(
        _AutopilotControlSettings instance) =>
    <String, dynamic>{
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };

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
