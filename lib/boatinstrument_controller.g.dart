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

_HttpHeader _$HttpHeaderFromJson(Map<String, dynamic> json) => _HttpHeader(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$HttpHeaderToJson(_HttpHeader instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      version: (json['version'] as num?)?.toInt() ?? 2,
      valueSmoothing: (json['valueSmoothing'] as num?)?.toInt() ?? 1,
      discoverServer: json['discoverServer'] as bool? ?? true,
      signalkUrl: json['signalkUrl'] as String? ?? '',
      httpHeaders: (json['httpHeaders'] as List<dynamic>?)
              ?.map((e) => _HttpHeader.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      signalkMinPeriod: (json['signalkMinPeriod'] as num?)?.toInt() ?? 500,
      signalkConnectionTimeout:
          (json['signalkConnectionTimeout'] as num?)?.toInt() ?? 20000,
      realTimeDataTimeout:
          (json['realTimeDataTimeout'] as num?)?.toInt() ?? 10000,
      infrequentDataTimeout:
          (json['infrequentDataTimeout'] as num?)?.toInt() ?? 90000,
      clientID: json['clientID'] as String?,
      groupID: json['groupID'] as String? ?? '',
      allowRemoteControl: json['allowRemoteControl'] as bool? ?? false,
      supplementalGroupIDs: (json['supplementalGroupIDs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      authToken: json['authToken'] as String? ?? '',
      notificationMuteTimeout:
          (json['notificationMuteTimeout'] as num?)?.toInt() ?? 15,
      demoMode: json['demoMode'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? true,
      wrapPages: json['wrapPages'] as bool? ?? true,
      brightnessControl: json['brightnessControl'] as bool? ?? false,
      keepAwake: json['keepAwake'] as bool? ?? false,
      autoConfirmActions: json['autoConfirmActions'] as bool? ?? false,
      pageTimerOnStart: json['pageTimerOnStart'] as bool? ?? false,
      enableExperimentalBoxes:
          json['enableExperimentalBoxes'] as bool? ?? false,
      setTime: json['setTime'] as bool? ?? false,
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
      airPressureUnits: $enumDecodeNullable(
              _$AirPressureUnitsEnumMap, json['airPressureUnits']) ??
          AirPressureUnits.millibar,
      oilPressureUnits: $enumDecodeNullable(
              _$OilPressureUnitsEnumMap, json['oilPressureUnits']) ??
          OilPressureUnits.kpa,
      capacityUnits:
          $enumDecodeNullable(_$CapacityUnitsEnumMap, json['capacityUnits']) ??
              CapacityUnits.liter,
      fluidRateUnits: $enumDecodeNullable(
              _$FluidRateUnitsEnumMap, json['fluidRateUnits']) ??
          FluidRateUnits.litersPerHour,
      portStarboardColors: $enumDecodeNullable(
              _$PortStarboardColorsEnumMap, json['portStarboardColors']) ??
          PortStarboardColors.redGreen,
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => _Page.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      boxSettings: json['boxSettings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'version': instance.version,
      'valueSmoothing': instance.valueSmoothing,
      'discoverServer': instance.discoverServer,
      'signalkUrl': instance.signalkUrl,
      'httpHeaders': instance.httpHeaders,
      'signalkMinPeriod': instance.signalkMinPeriod,
      'signalkConnectionTimeout': instance.signalkConnectionTimeout,
      'realTimeDataTimeout': instance.realTimeDataTimeout,
      'infrequentDataTimeout': instance.infrequentDataTimeout,
      'clientID': instance.clientID,
      'groupID': instance.groupID,
      'allowRemoteControl': instance.allowRemoteControl,
      'supplementalGroupIDs': instance.supplementalGroupIDs.toList(),
      'authToken': instance.authToken,
      'notificationMuteTimeout': instance.notificationMuteTimeout,
      'demoMode': instance.demoMode,
      'darkMode': instance.darkMode,
      'wrapPages': instance.wrapPages,
      'brightnessControl': instance.brightnessControl,
      'keepAwake': instance.keepAwake,
      'autoConfirmActions': instance.autoConfirmActions,
      'pageTimerOnStart': instance.pageTimerOnStart,
      'enableExperimentalBoxes': instance.enableExperimentalBoxes,
      'setTime': instance.setTime,
      'distanceUnits': _$DistanceUnitsEnumMap[instance.distanceUnits]!,
      'm2nmThreshold': instance.m2nmThreshold,
      'speedUnits': _$SpeedUnitsEnumMap[instance.speedUnits]!,
      'windSpeedUnits': _$SpeedUnitsEnumMap[instance.windSpeedUnits]!,
      'depthUnits': _$DepthUnitsEnumMap[instance.depthUnits]!,
      'temperatureUnits': _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
      'airPressureUnits': _$AirPressureUnitsEnumMap[instance.airPressureUnits]!,
      'oilPressureUnits': _$OilPressureUnitsEnumMap[instance.oilPressureUnits]!,
      'capacityUnits': _$CapacityUnitsEnumMap[instance.capacityUnits]!,
      'fluidRateUnits': _$FluidRateUnitsEnumMap[instance.fluidRateUnits]!,
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
  TemperatureUnits.k: 'k',
};

const _$AirPressureUnitsEnumMap = {
  AirPressureUnits.pascal: 'pascal',
  AirPressureUnits.millibar: 'millibar',
  AirPressureUnits.atmosphere: 'atmosphere',
  AirPressureUnits.mercury: 'mercury',
};

const _$OilPressureUnitsEnumMap = {
  OilPressureUnits.psi: 'psi',
  OilPressureUnits.kpa: 'kpa',
};

const _$CapacityUnitsEnumMap = {
  CapacityUnits.liter: 'liter',
  CapacityUnits.gallon: 'gallon',
  CapacityUnits.usGallon: 'usGallon',
};

const _$FluidRateUnitsEnumMap = {
  FluidRateUnits.litersPerHour: 'litersPerHour',
  FluidRateUnits.gallonsPerHour: 'gallonsPerHour',
  FluidRateUnits.usGallonsPerHour: 'usGallonsPerHour',
};

const _$PortStarboardColorsEnumMap = {
  PortStarboardColors.none: 'none',
  PortStarboardColors.redGreen: 'redGreen',
  PortStarboardColors.redBlue: 'redBlue',
  PortStarboardColors.orangeYellow: 'orangeYellow',
};

BackgroundDataSettings _$BackgroundDataSettingsFromJson(
        Map<String, dynamic> json) =>
    BackgroundDataSettings(
      dataDuration: $enumDecodeNullable(
              _$BackgroundDataDurationEnumMap, json['dataDuration']) ??
          BackgroundDataDuration.thirtyMinutes,
    );

Map<String, dynamic> _$BackgroundDataSettingsToJson(
        BackgroundDataSettings instance) =>
    <String, dynamic>{
      'dataDuration': _$BackgroundDataDurationEnumMap[instance.dataDuration]!,
    };

const _$BackgroundDataDurationEnumMap = {
  BackgroundDataDuration.thirtyMinutes: 'thirtyMinutes',
  BackgroundDataDuration.oneHour: 'oneHour',
  BackgroundDataDuration.twoHours: 'twoHours',
  BackgroundDataDuration.fourHours: 'fourHours',
  BackgroundDataDuration.sixHours: 'sixHours',
  BackgroundDataDuration.twelveHours: 'twelveHours',
  BackgroundDataDuration.oneDay: 'oneDay',
};
