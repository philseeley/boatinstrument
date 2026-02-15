// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnchorAlarmSettings _$AnchorAlarmSettingsFromJson(Map<String, dynamic> json) =>
    _AnchorAlarmSettings(
      recordSeconds: (json['recordSeconds'] as num?)?.toInt() ?? 10,
      recordPoints: (json['recordPoints'] as num?)?.toInt() ?? 1000,
      zoomIncrement: (json['zoomIncrement'] as num?)?.toDouble() ?? 0.25,
      signalkChart: json['signalkChart'] == null
          ? const SignalkChart()
          : SignalkChart.fromJson(json['signalkChart'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnchorAlarmSettingsToJson(
  _AnchorAlarmSettings instance,
) => <String, dynamic>{
  'recordSeconds': instance.recordSeconds,
  'recordPoints': instance.recordPoints,
  'zoomIncrement': instance.zoomIncrement,
  'signalkChart': instance.signalkChart.toJson(),
};
