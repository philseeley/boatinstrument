// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electrical_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ElectricalSettings _$ElectricalSettingsFromJson(Map<String, dynamic> json) =>
    _ElectricalSettings(
      id: json['id'] as String? ?? '',
    );

Map<String, dynamic> _$ElectricalSettingsToJson(_ElectricalSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

_ElectricalBatterySettings _$ElectricalBatterySettingsFromJson(
        Map<String, dynamic> json) =>
    _ElectricalBatterySettings(
      id: json['id'] as String? ?? '',
      voltage: $enumDecodeNullable(_$BatteryVoltageEnumMap, json['voltage']) ??
          BatteryVoltage.twelve,
    );

Map<String, dynamic> _$ElectricalBatterySettingsToJson(
        _ElectricalBatterySettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'voltage': _$BatteryVoltageEnumMap[instance.voltage]!,
    };

const _$BatteryVoltageEnumMap = {
  BatteryVoltage.twelve: 'twelve',
  BatteryVoltage.twentyFour: 'twentyFour',
  BatteryVoltage.fortyEight: 'fortyEight',
};

_ElectricalSwitchesSettings _$ElectricalSwitchesSettingsFromJson(
        Map<String, dynamic> json) =>
    _ElectricalSwitchesSettings(
      useSliderForDimming: json['useSliderForDimming'] as bool? ?? false,
      clientID: json['clientID'],
      authToken: json['authToken'] as String? ?? '',
    );

Map<String, dynamic> _$ElectricalSwitchesSettingsToJson(
        _ElectricalSwitchesSettings instance) =>
    <String, dynamic>{
      'useSliderForDimming': instance.useSliderForDimming,
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };
