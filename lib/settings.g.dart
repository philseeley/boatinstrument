// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      valueSmoothing: json['valueSmoothing'] as int? ?? 0,
      signalkServer:
          json['signalkServer'] as String? ?? 'openplotter.local:3000',
      widgetSettings:
          json['widgetSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'valueSmoothing': instance.valueSmoothing,
      'signalkServer': instance.signalkServer,
      'widgetSettings': instance.widgetSettings,
    };
