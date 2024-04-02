enum AutoPilotState {
  off('Off'),
  auto('Auto'),
  track('Track'),
  vane('Vane');

  final String name;

  const AutoPilotState(this.name);
}

class AutoPilot {
  AutoPilotState status = AutoPilotState.off;
  int heading = 0;
  int vaneAngle = 0;
  String goto = "";

  int cog = 0;
  int apparentWindAngle = 0;
}