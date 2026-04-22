// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anchor_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnchorAlarmSettings _$AnchorAlarmSettingsFromJson(Map<String, dynamic> json) =>
    _AnchorAlarmSettings(
      recordSeconds: (json['recordSeconds'] as num?)?.toInt() ?? 10,
      recordPoints: (json['recordPoints'] as num?)?.toInt() ?? 1000,
      sampleRadius: (json['sampleRadius'] as num?)?.toDouble() ?? 30,
      zoomIncrement: (json['zoomIncrement'] as num?)?.toDouble() ?? 0.5,
      signalkChart: json['signalkChart'] == null
          ? const SignalkChart()
          : SignalkChart.fromJson(json['signalkChart'] as Map<String, dynamic>),
      startWithChart: json['startWithChart'] as bool? ?? true,
    );

Map<String, dynamic> _$AnchorAlarmSettingsToJson(
  _AnchorAlarmSettings instance,
) => <String, dynamic>{
  'recordSeconds': instance.recordSeconds,
  'recordPoints': instance.recordPoints,
  'sampleRadius': instance.sampleRadius,
  'zoomIncrement': instance.zoomIncrement,
  'signalkChart': instance.signalkChart.toJson(),
  'startWithChart': instance.startWithChart,
};
