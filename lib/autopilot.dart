enum AutoPilotState {
  standby('standby', 'Standby'),
  auto('auto', 'Auto'),
  track('track', 'Track'),
  vane('vane', 'Vane');

  final String value;
  final String displayName;

  const AutoPilotState(this.value, this.displayName);

  static AutoPilotState get(String value) {
    for (var entry in AutoPilotState.values) {
      if (entry.value == value) {
        return entry;
      }
    }

    throw Exception("Unknown AutoPilotState: $value");
  }
}

class AutoPilot {
  AutoPilotState state = AutoPilotState.standby; // steering.autopilot.state
  int heading = 0; // steering.autopilot.target.headingMagnetic + navigation.magneticVariation
  int vaneAngle = 0; // steering.autopilot.target.windAngleApparent
  String waypoint = ""; // navigation.currentRoute.waypoints[1]

  int cog = 0; // navigation.courseOverGroundTrue
  int apparentWindAngle = 0; //environment.wind.angleApparent
}