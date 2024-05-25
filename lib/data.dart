part of 'boatinstrument_controller.dart';

int rad2Deg(double? rad) => ((rad??0) * vm.radians2Degrees).round();
double deg2Rad(int? deg) => (deg??0) * vm.degrees2Radians;
double meters2NM(double m) => double.parse((m*0.00054).toStringAsPrecision(2));
String val2PS(num val) => val < 0 ? 'P' : 'S';

double averageAngle(double current, double next, { int smooth = 1, bool relative=false }) {
  vm.Vector2 v1 = vm.Vector2(m.sin(current) * smooth, m.cos(current) * smooth);
  vm.Vector2 v2 = vm.Vector2(m.sin(next), m.cos(next));

  vm.Vector2 avg = (v1 + v2) / 2;

  double avga = m.atan2(avg.x, avg.y);

  return ((avga >= 0) || relative) ? avga : ((2 * m.pi) + avga);
}

double averageDouble(double current, double next, { int smooth = 1 }) {
  return ((current * smooth) + next) / (1 + smooth);
}

// Assumption is that the font characters are higher than they are wide.
// NOTE: the style MUST have the height set to 1.0.
double maxFontSize(String text, TextStyle style, double availableHeight, double availableWidth) {
  // Haven't worked out why the "- 1.0" is required.
  double fontSize = availableHeight - 1.0;

  // We use this to determine the relationship between the font height and width, as we can only
  // control the font size by its height.

  TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style.copyWith(fontSize: fontSize)), maxLines: 1, textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);

  // Check if we're constrained by width.
  if(textPainter.size.width > availableWidth) {
    fontSize = (fontSize * (availableWidth / textPainter.size.width)) - 1.0;
  }

  return fontSize;
}

abstract class BoxSettings {}

abstract class BoxWidget extends StatefulWidget {
  final BoatInstrumentController controller;
  final BoxConstraints constraints;

  const BoxWidget(this.controller, this.constraints, {super.key});

  String get id;

  bool get hasSettings => false;

  Widget? getSettingsWidget(Map<String, dynamic> json) {
    return null;
  }

  Map<String, dynamic> getSettingsJson() {
    return {};
  }
}

class BlankBox extends BoxWidget {

  const BlankBox(super.controller, super.constraints, {super.key});

  static const String sid = '_BLANK_';
  @override
  String get id => sid;

  @override
  State<BlankBox> createState() => _BlankBoxState();
}

class _BlankBoxState extends State<BlankBox> {

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WidgetDetails {
  final String id;
  final String description;
  final BoxWidget Function(BoatInstrumentController, BoxConstraints constraints) build;

  WidgetDetails(this.id, this.description, this.build);
}

//TODO widget for web page. Can't find a WebView widget that works on macos so difficult to test.
//TODO rudder angle
List<WidgetDetails> widgetDetails = [
  WidgetDetails(BlankBox.sid, 'Blank', (controller, constraints) {return BlankBox(controller, constraints, key: UniqueKey());}), // This is the default Box.
  WidgetDetails(DepthBox.sid, 'Depth', (controller, constraints) {return DepthBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(SpeedBox.sid, 'Speed Through Water', (controller, constraints) {return SpeedBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(SpeedOverGroundBox.sid, 'Speed Over Ground', (controller, constraints) {return SpeedOverGroundBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(WindSpeedApparentBox.sid, 'Wind Speed Apparent', (controller, constraints) {return WindSpeedApparentBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(WindSpeedTrueBox.sid, 'Wind Speed True', (controller, constraints) {return WindSpeedTrueBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(WindRoseBox.sid, 'Wind Rose', (controller, constraints) {return WindRoseBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(WindRoseCHBox.sid, 'Wind Rose CH', (controller, constraints) {return WindRoseCHBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(PositionBox.sid, 'Position', (controller, constraints) {return PositionBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(CourseOverGroundBox.sid, 'Course Over Ground', (controller, constraints) {return CourseOverGroundBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(SeaTemperatureBox.sid, 'Sea Temperature', (controller, constraints) {return SeaTemperatureBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(AutoPilotStatusBox.sid, 'Autopilot Status', (controller, constraints) {return AutoPilotStatusBox(controller, constraints, key: UniqueKey());}),
  WidgetDetails(AutoPilotControlBox.sid, 'Autopilot Control', (controller, constraints) {return AutoPilotControlBox(controller, constraints, key: UniqueKey());}),
];

WidgetDetails getWidgetDetails(String id) {
  for(WidgetDetails wd in widgetDetails) {
    if(wd.id == id) {
      return wd;
    }
  }

  CircularLogger().e('Unknown widget with ID $id', error: Exception('Unknown widget with ID $id'));
  return widgetDetails[0];
}

class Update {
  final String path;
  final dynamic value;

  Update(this.path, this.value);
}

typedef OnUpdate = Function(List<Update> updates);

class _WidgetData {
  Widget widget;
  bool configured = false;
  OnUpdate? onUpdate;
  Set<String> paths = {};
  List<Update> updates = [];

  _WidgetData(this.widget);
}

class _Resizable {
  double percentage;

  _Resizable(this.percentage);
}

@JsonSerializable()
class _Box extends _Resizable{
  String id;

  _Box(this.id, super.percentage);

  factory _Box.fromJson(Map<String, dynamic> json) =>
      _$BoxFromJson(json);

  Map<String, dynamic> toJson() => _$BoxToJson(this);
}

@JsonSerializable()
class _Row extends _Resizable{
  List<_Box> boxes;

  _Row(this.boxes, super.percentage);

  factory _Row.fromJson(Map<String, dynamic> json) =>
      _$RowFromJson(json);

  Map<String, dynamic> toJson() => _$RowToJson(this);
}

@JsonSerializable()
class _Column extends _Resizable{
  List<_Row> rows;

  _Column(this.rows, super.percentage);

  factory _Column.fromJson(Map<String, dynamic> json) =>
      _$ColumnFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnToJson(this);
}

@JsonSerializable()
class _Page {
  String name;
  List<_Column> columns;

  _Page(this.name, this.columns);

  factory _Page.fromJson(Map<String, dynamic> json) =>
      _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);

  static _Page _newPage() => _Page('Page Name', [_Column([_Row([_Box(widgetDetails[0].id, 1.0)], 1)], 1)]);
}

enum SignalkPolicy {
  instant('Instant'),
  ideal('Ideal'),
  fixed('Fixed');

  final String displayName;

  const SignalkPolicy(this.displayName);
}

enum DistanceUnits {
  meters('Meters', 'm'),
  km('Kilometers', 'km'),
  miles('Miles', 'mile'),
  nm('Nautical Miles', 'nm');

  final String displayName;
  final String unit;

  const DistanceUnits(this.displayName, this.unit);
}

enum SpeedUnits {
  mps('M/S', 'm/s'),
  kph('KPH', 'km/h'),
  mph('MPH', 'mph'),
  kts('Knots', 'kts');

  final String displayName;
  final String unit;

  const SpeedUnits(this.displayName, this.unit);
}

enum DepthUnits {
  m('Meters', 'm'),
  ft('Feet', 'ft'),
  fa('Fathom', 'Fa');

  final String displayName;
  final String unit;

  const DepthUnits(this.displayName, this.unit);
}

enum TemperatureUnits {
  c('Centigrade', 'C'),
  f('Fahrenheit', 'F');

  final String displayName;
  final String unit;

  const TemperatureUnits(this.displayName, this.unit);
}

@JsonSerializable()
class _Settings {
  int version;
  int valueSmoothing;
  String signalkServer;
  SignalkPolicy signalkPolicy;
  int signalkMinPeriod;
  bool wrapPages;
  bool keepAwake;
  bool autoConfirmActions;
  DistanceUnits distanceUnits;
  SpeedUnits speedUnits;
  SpeedUnits windSpeedUnits;
  DepthUnits depthUnits;
  TemperatureUnits temperatureUnits;
  late List<_Page> pages;
  late Map<String, dynamic> widgetSettings;

  static File? _store;

  String get fileName => _store!.absolute.path;

  _Settings({
    this.version = 0,
    this.valueSmoothing = 1,
    this.signalkServer = 'openplotter.local:3000',
    this.signalkPolicy = SignalkPolicy.instant,
    this.signalkMinPeriod = 1000,
    this.wrapPages = true,
    this.keepAwake = false,
    this.autoConfirmActions = false,
    this.distanceUnits = DistanceUnits.nm,
    this.speedUnits = SpeedUnits.kts,
    this.windSpeedUnits = SpeedUnits.kts,
    this.depthUnits = DepthUnits.m,
    this.temperatureUnits = TemperatureUnits.c,
    this.pages = const [],
    widgetSettings
  }) : widgetSettings = widgetSettings??{} {
    if(pages.isEmpty) {
      pages = [_Page._newPage()];
    }
  }

  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Future<_Settings> load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    return await readSettings(_store!);
  }

  static readSettings(File f) async {
    String s = f.readAsStringSync();
    dynamic data = json.decode(s);
    return _Settings.fromJson(data);
  }

  _save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}
