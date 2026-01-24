// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnchorAlarmSettings _$AnchorAlarmSettingsFromJson(Map<String, dynamic> json) =>
    _AnchorAlarmSettings(
      recordSeconds: (json['recordSeconds'] as num?)?.toInt() ?? 10,
      recordPoints: (json['recordPoints'] as num?)?.toInt() ?? 1000,
    );

Map<String, dynamic> _$AnchorAlarmSettingsToJson(
  _AnchorAlarmSettings instance,
) => <String, dynamic>{
  'recordSeconds': instance.recordSeconds,
  'recordPoints': instance.recordPoints,
};
