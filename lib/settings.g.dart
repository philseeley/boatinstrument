// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      enableLock: json['enableLock'] as bool? ?? true,
      lockSeconds: json['lockSeconds'] as int? ?? 5,
      signalkServer:
          json['signalkServer'] as String? ?? 'openplotter.local:3000',
      clientID: json['clientID'] as String? ?? 'nav-1234',
      authToken: json['authToken'] as String? ?? "",
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'enableLock': instance.enableLock,
      'lockSeconds': instance.lockSeconds,
      'signalkServer': instance.signalkServer,
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };
