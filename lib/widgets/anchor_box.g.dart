// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnchorAlarmSettings _$AnchorAlarmSettingsFromJson(Map<String, dynamic> json) =>
    _AnchorAlarmSettings(
      clientID: json['clientID'],
      authToken: json['authToken'] as String? ?? '',
    );

Map<String, dynamic> _$AnchorAlarmSettingsToJson(
        _AnchorAlarmSettings instance) =>
    <String, dynamic>{
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };
