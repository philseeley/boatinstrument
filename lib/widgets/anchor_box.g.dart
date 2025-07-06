// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnchorAlarmSettings _$AnchorAlarmSettingsFromJson(Map<String, dynamic> json) =>
    _AnchorAlarmSettings(
      clientID: json['clientID'] as String?,
      authToken: json['authToken'] as String? ?? '',
      recordSeconds: (json['recordSeconds'] as num?)?.toInt() ?? 10,
      recordPoints: (json['recordPoints'] as num?)?.toInt() ?? 1000,
    );

Map<String, dynamic> _$AnchorAlarmSettingsToJson(
        _AnchorAlarmSettings instance) =>
    <String, dynamic>{
      'clientID': instance.clientID,
      'authToken': instance.authToken,
      'recordSeconds': instance.recordSeconds,
      'recordPoints': instance.recordPoints,
    };
