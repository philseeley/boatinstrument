// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boatinstrument_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Box _$BoxFromJson(Map<String, dynamic> json) => _Box(
      json['id'] as String,
      json['settings'] as Map<String, dynamic>,
      (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$BoxToJson(_Box instance) => <String, dynamic>{
      'percentage': instance.percentage,
      'id': instance.id,
      'settings': instance.settings,
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

_PageRow _$PageRowFromJson(Map<String, dynamic> json) => _PageRow(
      (json['columns'] as List<dynamic>)
          .map((e) => _Column.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$PageRowToJson(_PageRow instance) => <String, dynamic>{
      'percentage': instance.percentage,
      'columns': instance.columns,
    };

_Page _$PageFromJson(Map<String, dynamic> json) => _Page(
      json['name'] as String,
      (json['timeout'] as num?)?.toInt(),
      (json['pageRows'] as List<dynamic>)
          .map((e) => _PageRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageToJson(_Page instance) => <String, dynamic>{
      'name': instance.name,
      'timeout': instance.timeout,
      'pageRows': instance.pageRows,
    };

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      version: (json['version'] as num?)?.toInt() ?? 0,
      valueSmoothing: (json['valueSmoothing'] as num?)?.toInt() ?? 1,
      discoverServer: json['discoverServer'] as bool? ?? true,
      signalkHost: json['signalkHost'] as String? ?? '',
      signalkPort: (json['signalkPort'] as num?)?.toInt() ?? 3000,
      signalkMinPeriod: (json['signalkMinPeriod'] as num?)?.toInt() ?? 500,
      signalkConnectionTimeout:
          (json['signalkConnectionTimeout'] as num?)?.toInt() ?? 20000,
      dataTimeout: (json['dataTimeout'] as num?)?.toInt() ?? 10000,
      demoMode: json['demoMode'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? true,
      wrapPages: json['wrapPages'] as bool? ?? true,
      brightnessControl: json['brightnessControl'] as bool? ?? false,
      keepAwake: json['keepAwake'] as bool? ?? false,
      autoConfirmActions: json['autoConfirmActions'] as bool? ?? false,
      pageTimerOnStart: json['pageTimerOnStart'] as bool? ?? false,
      distanceUnits:
          $enumDecodeNullable(_$DistanceUnitsEnumMap, json['distanceUnits']) ??
              DistanceUnits.nm,
      m2nmThreshold: (json['m2nmThreshold'] as num?)?.toInt() ?? 500,
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
      pressureUnits:
          $enumDecodeNullable(_$PressureUnitsEnumMap, json['pressureUnits']) ??
              PressureUnits.millibar,
      portStarboardColors: $enumDecodeNullable(
              _$PortStarboardColorsEnumMap, json['portStarboardColors']) ??
          PortStarboardColors.redGreen,
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => _Page.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    )..boxSettings = json['boxSettings'] as Map<String, dynamic>;

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'version': instance.version,
      'valueSmoothing': instance.valueSmoothing,
      'discoverServer': instance.discoverServer,
      'signalkHost': instance.signalkHost,
      'signalkPort': instance.signalkPort,
      'signalkMinPeriod': instance.signalkMinPeriod,
      'signalkConnectionTimeout': instance.signalkConnectionTimeout,
      'dataTimeout': instance.dataTimeout,
      'demoMode': instance.demoMode,
      'darkMode': instance.darkMode,
      'wrapPages': instance.wrapPages,
      'brightnessControl': instance.brightnessControl,
      'keepAwake': instance.keepAwake,
      'autoConfirmActions': instance.autoConfirmActions,
      'pageTimerOnStart': instance.pageTimerOnStart,
      'distanceUnits': _$DistanceUnitsEnumMap[instance.distanceUnits]!,
      'm2nmThreshold': instance.m2nmThreshold,
      'speedUnits': _$SpeedUnitsEnumMap[instance.speedUnits]!,
      'windSpeedUnits': _$SpeedUnitsEnumMap[instance.windSpeedUnits]!,
      'depthUnits': _$DepthUnitsEnumMap[instance.depthUnits]!,
      'temperatureUnits': _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
      'pressureUnits': _$PressureUnitsEnumMap[instance.pressureUnits]!,
      'portStarboardColors':
          _$PortStarboardColorsEnumMap[instance.portStarboardColors]!,
      'pages': instance.pages,
      'boxSettings': instance.boxSettings,
    };

const _$DistanceUnitsEnumMap = {
  DistanceUnits.meters: 'meters',
  DistanceUnits.km: 'km',
  DistanceUnits.miles: 'miles',
  DistanceUnits.nm: 'nm',
  DistanceUnits.nmM: 'nmM',
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

const _$PressureUnitsEnumMap = {
  PressureUnits.pascal: 'pascal',
  PressureUnits.millibar: 'millibar',
  PressureUnits.atmosphere: 'atmosphere',
  PressureUnits.mercury: 'mercury',
};

const _$PortStarboardColorsEnumMap = {
  PortStarboardColors.none: 'none',
  PortStarboardColors.redGreen: 'redGreen',
  PortStarboardColors.redBlue: 'redBlue',
  PortStarboardColors.orangeYellow: 'orangeYellow',
};
