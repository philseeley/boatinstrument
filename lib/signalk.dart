import 'dart:ffi';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

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

  Steering({
    this.autopilot
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

int rad2Deg(double? rad) => ((rad??0) * 57.29578).round();
double deg2Rad(int? deg) => (deg??0) / 57.29578;
double meters2NM(double m) => double.parse((m*0.00054).toStringAsPrecision(2));
String val2PS(num val) => val < 0 ? 'P' : 'S';

double averageAngle(double angle1, double angle2) {
  double min, max;

  if(angle1 < angle2) {
    min = angle1;
    max = angle2;
  } else {
    min = angle2;
    max = angle1;
  }

  if(max - min < pi) {
    return (max + min) / 2;
  } else {
    return ((max + (min+(2*pi))) / 2) % (2*pi);
  }
}

double smoothAngle(double current, double latest, int smooth) {
  double average = averageAngle(current, latest);

  double min, max;

  if(current < average) {
    min = current;
    max = average;
  } else {
    min = average;
    max = current;
  }

  if(max - min < pi) {
    if(current < average) {
      return current + ((max - min) / smooth);
    } else {
      return current - ((max - min) / smooth);
    }
  } else {
    double diff = ((min+(2*pi)) - max) / smooth;

    if(current < average) {
      double r = current - diff;
      return r<0 ? r+(2*pi) : r;
    } else {
      return (current + diff) % (2*pi);
    }
  }
}
