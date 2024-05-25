// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boatinstrument_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Box _$BoxFromJson(Map<String, dynamic> json) => _Box(
      json['id'] as String,
      (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$BoxToJson(_Box instance) => <String, dynamic>{
      'percentage': instance.percentage,
      'id': instance.id,
    };

_Row _$RowFromJson(Map<String, dynamic> json) => _Row(
      (json['boxes'] as List<dynamic>)
          .map((e) => _Box.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$RowToJson(_Row instance) => <String, dynamic>{
      'percentage': instance.percentage,
      'boxes': instance.boxes,
    };

_Column _$ColumnFromJson(Map<String, dynamic> json) => _Column(
      (json['rows'] as List<dynamic>)
          .map((e) => _Row.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$ColumnToJson(_Column instance) => <String, dynamic>{
      'percentage': instance.percentage,
      'rows': instance.rows,
    };

_Page _$PageFromJson(Map<String, dynamic> json) => _Page(
      json['name'] as String,
      (json['columns'] as List<dynamic>)
          .map((e) => _Column.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageToJson(_Page instance) => <String, dynamic>{
      'name': instance.name,
      'columns': instance.columns,
    };

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      version: json['version'] as int? ?? 0,
      valueSmoothing: json['valueSmoothing'] as int? ?? 1,
      signalkServer:
          json['signalkServer'] as String? ?? 'openplotter.local:3000',
      signalkPolicy:
          $enumDecodeNullable(_$SignalkPolicyEnumMap, json['signalkPolicy']) ??
              SignalkPolicy.instant,
      signalkMinPeriod: json['signalkMinPeriod'] as int? ?? 1000,
      darkMode: json['darkMode'] as bool? ?? true,
      wrapPages: json['wrapPages'] as bool? ?? true,
      keepAwake: json['keepAwake'] as bool? ?? false,
      autoConfirmActions: json['autoConfirmActions'] as bool? ?? false,
      distanceUnits:
          $enumDecodeNullable(_$DistanceUnitsEnumMap, json['distanceUnits']) ??
              DistanceUnits.nm,
      speedUnits:
          $enumDecodeNullable(_$SpeedUnitsEnumMap, json['speedUnits']) ??
              SpeedUnits.kts,
      windSpeedUnits:
          $enumDecodeNullable(_$SpeedUnitsEnumMap, json['windSpeedUnits']) ??
              SpeedUnits.kts,
      depthUnits:
          $enumDecodeNullable(_$DepthUnitsEnumMap, json['depthUnits']) ??
              DepthUnits.m,
      temperatureUnits: $enumDecodeNullable(
              _$TemperatureUnitsEnumMap, json['temperatureUnits']) ??
          TemperatureUnits.c,
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => _Page.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      widgetSettings: json['widgetSettings'],
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'version': instance.version,
      'valueSmoothing': instance.valueSmoothing,
      'signalkServer': instance.signalkServer,
      'signalkPolicy': _$SignalkPolicyEnumMap[instance.signalkPolicy]!,
      'signalkMinPeriod': instance.signalkMinPeriod,
      'darkMode': instance.darkMode,
      'wrapPages': instance.wrapPages,
      'keepAwake': instance.keepAwake,
      'autoConfirmActions': instance.autoConfirmActions,
      'distanceUnits': _$DistanceUnitsEnumMap[instance.distanceUnits]!,
      'speedUnits': _$SpeedUnitsEnumMap[instance.speedUnits]!,
      'windSpeedUnits': _$SpeedUnitsEnumMap[instance.windSpeedUnits]!,
      'depthUnits': _$DepthUnitsEnumMap[instance.depthUnits]!,
      'temperatureUnits': _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
      'pages': instance.pages,
      'widgetSettings': instance.widgetSettings,
    };

const _$SignalkPolicyEnumMap = {
  SignalkPolicy.instant: 'instant',
  SignalkPolicy.ideal: 'ideal',
  SignalkPolicy.fixed: 'fixed',
};

const _$DistanceUnitsEnumMap = {
  DistanceUnits.meters: 'meters',
  DistanceUnits.km: 'km',
  DistanceUnits.miles: 'miles',
  DistanceUnits.nm: 'nm',
};

const _$SpeedUnitsEnumMap = {
  SpeedUnits.mps: 'mps',
  SpeedUnits.kph: 'kph',
  SpeedUnits.mph: 'mph',
  SpeedUnits.kts: 'kts',
};

const _$DepthUnitsEnumMap = {
  DepthUnits.m: 'm',
  DepthUnits.ft: 'ft',
  DepthUnits.fa: 'fa',
};

const _$TemperatureUnitsEnumMap = {
  TemperatureUnits.c: 'c',
  TemperatureUnits.f: 'f',
};
