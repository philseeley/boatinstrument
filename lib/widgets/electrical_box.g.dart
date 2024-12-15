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

_ElectricalSwitchesSettings _$ElectricalSwitchesSettingsFromJson(
        Map<String, dynamic> json) =>
    _ElectricalSwitchesSettings(
      clientID: json['clientID'],
      authToken: json['authToken'] as String? ?? '',
    );

Map<String, dynamic> _$ElectricalSwitchesSettingsToJson(
        _ElectricalSwitchesSettings instance) =>
    <String, dynamic>{
      'clientID': instance.clientID,
      'authToken': instance.authToken,
    };

_PerBoxElectricalSwitchesSettings _$PerBoxElectricalSwitchesSettingsFromJson(
        Map<String, dynamic> json) =>
    _PerBoxElectricalSwitchesSettings(
      useSlider: json['useSlider'] as bool? ?? false,
    );

Map<String, dynamic> _$PerBoxElectricalSwitchesSettingsToJson(
        _PerBoxElectricalSwitchesSettings instance) =>
    <String, dynamic>{
      'useSlider': instance.useSlider,
    };
