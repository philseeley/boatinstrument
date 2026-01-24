// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autopilot_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutopilotControlPerBoxSettings _$AutopilotControlPerBoxSettingsFromJson(
  Map<String, dynamic> json,
) => _AutopilotControlPerBoxSettings(
  enableLock: json['enableLock'] as bool? ?? true,
  lockSeconds: (json['lockSeconds'] as num?)?.toInt() ?? 5,
  showLabels: json['showLabels'] as bool? ?? true,
);

Map<String, dynamic> _$AutopilotControlPerBoxSettingsToJson(
  _AutopilotControlPerBoxSettings instance,
) => <String, dynamic>{
  'enableLock': instance.enableLock,
  'lockSeconds': instance.lockSeconds,
  'showLabels': instance.showLabels,
};

_AutopilotReefingSettings _$AutopilotReefingSettingsFromJson(
  Map<String, dynamic> json,
) => _AutopilotReefingSettings(
  upwindAngle: (json['upwindAngle'] as num?)?.toInt() ?? 50,
  downwindAngle: (json['downwindAngle'] as num?)?.toInt() ?? 130,
);

Map<String, dynamic> _$AutopilotReefingSettingsToJson(
  _AutopilotReefingSettings instance,
) => <String, dynamic>{
  'upwindAngle': instance.upwindAngle,
  'downwindAngle': instance.downwindAngle,
};
