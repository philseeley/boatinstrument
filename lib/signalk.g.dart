// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signalk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StringValue _$StringValueFromJson(Map<String, dynamic> json) => StringValue(
      value: json['value'] as String? ?? '',
    );

Map<String, dynamic> _$StringValueToJson(StringValue instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

DoubleValue _$DoubleValueFromJson(Map<String, dynamic> json) => DoubleValue(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$DoubleValueToJson(DoubleValue instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

Wind _$WindFromJson(Map<String, dynamic> json) => Wind(
      speedApparent: json['speedApparent'] == null
          ? null
          : DoubleValue.fromJson(json['speedApparent'] as Map<String, dynamic>),
      angleApparent: json['angleApparent'] == null
          ? null
          : DoubleValue.fromJson(json['angleApparent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WindToJson(Wind instance) => <String, dynamic>{
      'speedApparent': instance.speedApparent,
      'angleApparent': instance.angleApparent,
    };

Environment _$EnvironmentFromJson(Map<String, dynamic> json) => Environment(
      wind: json['wind'] == null
          ? null
          : Wind.fromJson(json['wind'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnvironmentToJson(Environment instance) =>
    <String, dynamic>{
      'wind': instance.wind,
    };

Target _$TargetFromJson(Map<String, dynamic> json) => Target(
      headingMagnetic: json['headingMagnetic'] == null
          ? null
          : DoubleValue.fromJson(
              json['headingMagnetic'] as Map<String, dynamic>),
      windAngleApparent: json['windAngleApparent'] == null
          ? null
          : DoubleValue.fromJson(
              json['windAngleApparent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TargetToJson(Target instance) => <String, dynamic>{
      'headingMagnetic': instance.headingMagnetic,
      'windAngleApparent': instance.windAngleApparent,
    };

AutopilotStateValue _$AutopilotStateValueFromJson(Map<String, dynamic> json) =>
    AutopilotStateValue(
      value: $enumDecodeNullable(_$AutopilotStateEnumMap, json['value']) ??
          AutopilotState.standby,
    );

Map<String, dynamic> _$AutopilotStateValueToJson(
        AutopilotStateValue instance) =>
    <String, dynamic>{
      'value': _$AutopilotStateEnumMap[instance.value]!,
    };

const _$AutopilotStateEnumMap = {
  AutopilotState.standby: 'standby',
  AutopilotState.auto: 'auto',
  AutopilotState.track: 'track',
  AutopilotState.vane: 'vane',
};

Autopilot _$AutopilotFromJson(Map<String, dynamic> json) => Autopilot(
      state: json['state'] == null
          ? null
          : AutopilotStateValue.fromJson(json['state'] as Map<String, dynamic>),
      target: json['target'] == null
          ? null
          : Target.fromJson(json['target'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AutopilotToJson(Autopilot instance) => <String, dynamic>{
      'state': instance.state,
      'target': instance.target,
    };

Steering _$SteeringFromJson(Map<String, dynamic> json) => Steering(
      autopilot: json['autopilot'] == null
          ? null
          : Autopilot.fromJson(json['autopilot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SteeringToJson(Steering instance) => <String, dynamic>{
      'autopilot': instance.autopilot,
    };

Waypoint _$WaypointFromJson(Map<String, dynamic> json) => Waypoint(
      name: json['name'] as String?,
    );

Map<String, dynamic> _$WaypointToJson(Waypoint instance) => <String, dynamic>{
      'name': instance.name,
    };

WaypointValue _$WaypointValueFromJson(Map<String, dynamic> json) =>
    WaypointValue(
      value: (json['value'] as List<dynamic>?)
              ?.map((e) => Waypoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WaypointValueToJson(WaypointValue instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      waypoints: json['waypoints'] == null
          ? null
          : WaypointValue.fromJson(json['waypoints'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'waypoints': instance.waypoints,
    };

CourseGreatCircle _$CourseGreatCircleFromJson(Map<String, dynamic> json) =>
    CourseGreatCircle(
      crossTrackError: json['crossTrackError'] == null
          ? null
          : DoubleValue.fromJson(
              json['crossTrackError'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseGreatCircleToJson(CourseGreatCircle instance) =>
    <String, dynamic>{
      'crossTrackError': instance.crossTrackError,
    };

Navigation _$NavigationFromJson(Map<String, dynamic> json) => Navigation(
      courseOverGroundTrue: json['courseOverGroundTrue'] == null
          ? null
          : DoubleValue.fromJson(
              json['courseOverGroundTrue'] as Map<String, dynamic>),
      magneticVariation: json['magneticVariation'] == null
          ? null
          : DoubleValue.fromJson(
              json['magneticVariation'] as Map<String, dynamic>),
      currentRoute: json['currentRoute'] == null
          ? null
          : Route.fromJson(json['currentRoute'] as Map<String, dynamic>),
    )..courseGreatCircle = json['courseGreatCircle'] == null
        ? null
        : CourseGreatCircle.fromJson(
            json['courseGreatCircle'] as Map<String, dynamic>);

Map<String, dynamic> _$NavigationToJson(Navigation instance) =>
    <String, dynamic>{
      'courseOverGroundTrue': instance.courseOverGroundTrue,
      'magneticVariation': instance.magneticVariation,
      'currentRoute': instance.currentRoute,
      'courseGreatCircle': instance.courseGreatCircle,
    };

Vessel _$VesselFromJson(Map<String, dynamic> json) => Vessel(
      environment: json['environment'] == null
          ? null
          : Environment.fromJson(json['environment'] as Map<String, dynamic>),
    )
      ..steering = json['steering'] == null
          ? null
          : Steering.fromJson(json['steering'] as Map<String, dynamic>)
      ..navigation = json['navigation'] == null
          ? null
          : Navigation.fromJson(json['navigation'] as Map<String, dynamic>);

Map<String, dynamic> _$VesselToJson(Vessel instance) => <String, dynamic>{
      'environment': instance.environment,
      'steering': instance.steering,
      'navigation': instance.navigation,
    };
