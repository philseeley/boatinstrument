// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boat_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RudderAngleSettings _$RudderAngleSettingsFromJson(Map<String, dynamic> json) =>
    _RudderAngleSettings(
      showLabels: json['showLabels'] as bool? ?? true,
      maxAngle: (json['maxAngle'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$RudderAngleSettingsToJson(
        _RudderAngleSettings instance) =>
    <String, dynamic>{
      'showLabels': instance.showLabels,
      'maxAngle': instance.maxAngle,
    };
