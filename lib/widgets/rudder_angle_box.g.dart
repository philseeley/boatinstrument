// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rudder_angle_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      showLabels: json['showLabels'] as bool? ?? true,
      maxAngle: (json['maxAngle'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'showLabels': instance.showLabels,
      'maxAngle': instance.maxAngle,
    };
