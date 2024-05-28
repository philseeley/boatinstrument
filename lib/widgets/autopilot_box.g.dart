// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autopilot_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      enableLock: json['enableLock'] as bool? ?? true,
      lockSeconds: (json['lockSeconds'] as num?)?.toInt() ?? 3,
      clientID: json['clientID'],
      authToken: json['authToken'] as String? ?? '',
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'enableLock': instance.enableLock,
      'lockSeconds': instance.lockSeconds,
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };
