// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_pilot_control.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      enableLock: json['enableLock'] as bool? ?? true,
      lockSeconds: json['lockSeconds'] as int? ?? 3,
      clientID: json['clientID'] as String? ?? 'boatinstrument-autopilot-1234',
      authToken: json['authToken'] as String? ?? '',
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'enableLock': instance.enableLock,
      'lockSeconds': instance.lockSeconds,
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };
