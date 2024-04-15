import 'dart:math' as m;

import 'package:json_annotation/json_annotation.dart';
import 'package:vector_math/vector_math.dart' as vm;

part 'signalk.g.dart';

@JsonSerializable()
class StringValue {
  String value;

  StringValue({
    this.value = ''
  });

  factory StringValue.fromJson(Map<String, dynamic> json) =>
      _$StringValueFromJson(json);
}

@JsonSerializable()
class DoubleValue {
  double value;

  DoubleValue({
    this.value = 0.0
  });

  factory DoubleValue.fromJson(Map<String, dynamic> json) =>
      _$DoubleValueFromJson(json);
}

@JsonSerializable()
class Wind {
  DoubleValue? speedApparent;
  DoubleValue? angleApparent;

  Wind({
    this.speedApparent,
    this.angleApparent
  });

  factory Wind.fromJson(Map<String, dynamic> json) =>
      _$WindFromJson(json);
}

@JsonSerializable()
class Environment {
  Wind? wind;

  Environment({
    this.wind
  });

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);
}

@JsonSerializable()
class Target {
  DoubleValue? headingMagnetic;
  DoubleValue? windAngleApparent;

  Target({
    this.headingMagnetic,
    this.windAngleApparent
  });

  factory Target.fromJson(Map<String, dynamic> json) =>
      _$TargetFromJson(json);
}

enum AutopilotState {
  standby('Standby'),
  auto('Auto'),
  track('Track'),
  wind('Vane');

  final String name;

  const AutopilotState(this.name);
}

@JsonSerializable()
class AutopilotStateValue {
  AutopilotState value;

  AutopilotStateValue({
    this.value = AutopilotState.standby
  });

  factory AutopilotStateValue.fromJson(Map<String, dynamic> json) =>
      _$AutopilotStateValueFromJson(json);
}

@JsonSerializable()
class Autopilot {
  AutopilotStateValue? state;
  Target? target;

  Autopilot({
    this.state,
    this.target
  });

  factory Autopilot.fromJson(Map<String, dynamic> json) =>
      _$AutopilotFromJson(json);
}

@JsonSerializable()
class Steering {
  Autopilot? autopilot;
  DoubleValue? rudderAngle;

  Steering({
    this.autopilot,
    this.rudderAngle
  });

  factory Steering.fromJson(Map<String, dynamic> json) =>
      _$SteeringFromJson(json);
}

@JsonSerializable()
class Waypoint {
  String? name;

  Waypoint({
    this.name
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) =>
      _$WaypointFromJson(json);
}

@JsonSerializable()
class WaypointValue {
  List<Waypoint> value;

  WaypointValue({
    this.value = const []
  });

  factory WaypointValue.fromJson(Map<String, dynamic> json) =>
      _$WaypointValueFromJson(json);
}

@JsonSerializable()
class Route {
  WaypointValue? waypoints;

  Route({
    this.waypoints
  });

  factory Route.fromJson(Map<String, dynamic> json) =>
      _$RouteFromJson(json);
}

@JsonSerializable()
class CourseGreatCircle {
  DoubleValue? crossTrackError;

  CourseGreatCircle({
    this.crossTrackError,
  });

  factory CourseGreatCircle.fromJson(Map<String, dynamic> json) =>
      _$CourseGreatCircleFromJson(json);
}

@JsonSerializable()
class Navigation {
  DoubleValue? courseOverGroundTrue;
  DoubleValue? magneticVariation;
  Route? currentRoute;
  CourseGreatCircle? courseGreatCircle;

  Navigation({
    this.courseOverGroundTrue,
    this.magneticVariation,
    this.currentRoute
  });

  factory Navigation.fromJson(Map<String, dynamic> json) =>
      _$NavigationFromJson(json);
}

@JsonSerializable()
class Vessel {
  Environment? environment;
  Steering? steering;
  Navigation? navigation;

  Vessel({
    this.environment
  });

  factory Vessel.fromJson(Map<String, dynamic> json) =>
      _$VesselFromJson(json);
}

int rad2Deg(double? rad) => ((rad??0) * vm.radians2Degrees).round();
double deg2Rad(int? deg) => (deg??0) * vm.degrees2Radians;
double meters2NM(double m) => double.parse((m*0.00054).toStringAsPrecision(2));
String val2PS(num val) => val < 0 ? 'P' : 'S';

double averageAngle(double current, double next, { int smooth = 0, bool relative=false }) {
  vm.Vector2 v1 = vm.Vector2(m.sin(current) * (50+smooth), m.cos(current) * (50+smooth));
  vm.Vector2 v2 = vm.Vector2(m.sin(next) * 50, m.cos(next) * 50);

  vm.Vector2 avg = (v1 + v2) / 2;

  double avga = m.atan2(avg.x, avg.y);

  return ((avga >= 0) || relative) ? avga : ((2 * m.pi) + avga);
}
