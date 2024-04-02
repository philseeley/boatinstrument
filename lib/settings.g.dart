// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      enableLock: json['enableLock'] as bool? ?? true,
      authToken: json['authToken'] as String? ?? "",
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'enableLock': instance.enableLock,
      'authToken': instance.authToken,
    };
