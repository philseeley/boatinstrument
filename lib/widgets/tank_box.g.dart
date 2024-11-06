// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tank_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TankSettings _$TankSettingsFromJson(Map<String, dynamic> json) =>
    _TankSettings(
      id: json['id'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$TankSettingsToJson(_TankSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'capacity': instance.capacity,
    };
