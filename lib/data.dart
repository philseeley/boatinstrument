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

  bool get hasPerBoxSettings => false;

  Widget? getPerBoxSettingsWidget() {
    return null;
  }

  Map<String, dynamic> getPerBoxSettingsJson() {
    return {};
  }

  Widget? getSettingsHelp() => null;
  Widget? getPerBoxSettingsHelp() => null;
}

class BlankBox extends BoxWidget {

  const BlankBox(super.controller, _, super.constraints, {super.key});

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

class HelpBox extends BoxWidget {

  const HelpBox(super.controller, _, super.constraints, {super.key});

  static const String sid = '_HELP_';
  @override
  String get id => sid;

  @override
  State<HelpBox> createState() => _HelpBoxState();
}

class _HelpBoxState extends State<HelpBox> {

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: IconButton(icon: const Icon(Icons.help), onPressed: _showHelpPage));
  }

  _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _HelpPage(widget.controller);
         })
    );
  }
}

class BoxDetails {
  final String id;
  final String description;
  final BoxWidget Function(BoatInstrumentController, Map<String, dynamic> settings, BoxConstraints) build;

  BoxDetails(this.id, this.description, this.build);
}

//TODO widget for web page. Can't find a WebView widget that works on macos so difficult to test.
//TODO rudder angle
List<BoxDetails> boxDetails = [
  BoxDetails(BlankBox.sid, 'Blank', (controller, settings, constraints) {return BlankBox(controller, settings, constraints, key: UniqueKey());}), // This is the default Box.
  BoxDetails(HelpBox.sid, 'Help', (controller, settings, constraints) {return HelpBox(controller, settings, constraints, key: UniqueKey());}), // This is the default Box.
  BoxDetails(DepthBox.sid, 'Depth', (controller, settings, constraints) {return DepthBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(SpeedBox.sid, 'Speed Through Water', (controller, settings, constraints) {return SpeedBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(SpeedOverGroundBox.sid, 'Speed Over Ground', (controller, settings, constraints) {return SpeedOverGroundBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(WindSpeedApparentBox.sid, 'Wind Speed Apparent', (controller, settings, constraints) {return WindSpeedApparentBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(WindSpeedTrueBox.sid, 'Wind Speed True', (controller, settings, constraints) {return WindSpeedTrueBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(WindRoseBox.sid, 'Wind Rose', (controller, settings, constraints) {return WindRoseBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(WindRoseCHBox.sid, 'Wind Rose CH', (controller, settings, constraints) {return WindRoseCHBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(PositionBox.sid, 'Position', (controller, settings, constraints) {return PositionBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(CourseOverGroundBox.sid, 'Course Over Ground', (controller, settings, constraints) {return CourseOverGroundBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(SeaTemperatureBox.sid, 'Sea Temperature', (controller, settings, constraints) {return SeaTemperatureBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(AutoPilotStatusBox.sid, 'Autopilot Status', (controller, settings, constraints) {return AutoPilotStatusBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(AutoPilotControlBox.sid, 'Autopilot Control', (controller, settings, constraints) {return AutoPilotControlBox(controller, settings, constraints, key: UniqueKey());}),
  BoxDetails(WebViewBox.sid, 'Web Page', (controller, settings, constraints) {return WebViewBox(controller, settings, constraints, key: UniqueKey());}),
];

BoxDetails getBoxDetails(String id) {
  for(BoxDetails wd in boxDetails) {
    if(wd.id == id) {
      return wd;
    }
  }

  CircularLogger().e('Unknown widget with ID $id', error: Exception('Unknown widget with ID $id'));
  return boxDetails[0];
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
  Map<String, dynamic> settings;

  _Box(this.id, this.settings, super.percentage);

  factory _Box.blank() {
    return _Box(BlankBox.sid, {}, 1.0);
  }

  factory _Box.help() {
    return _Box(HelpBox.sid, {}, 1.0);
  }

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

  static _Page _newPage() => _Page('Page Name', [_Column([_Row([_Box.help()], 1)], 1)]);
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
  bool darkMode;
  bool wrapPages;
  bool keepAwake;
  bool autoConfirmActions;
  DistanceUnits distanceUnits;
  SpeedUnits speedUnits;
  SpeedUnits windSpeedUnits;
  DepthUnits depthUnits;
  TemperatureUnits temperatureUnits;
  late List<_Page> pages;
  late Map<String, dynamic> boxSettings;

  static File? _store;

  String get fileName => _store!.absolute.path;

  _Settings({
    this.version = 0,
    this.valueSmoothing = 1,
    this.signalkServer = 'openplotter.local:3000',
    this.signalkPolicy = SignalkPolicy.instant,
    this.signalkMinPeriod = 1000,
    this.darkMode = true,
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
  }) : boxSettings = widgetSettings??{} {
    if(pages.isEmpty) {
      pages = [_Page._newPage()];
    }
  }

  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Future<_Settings> load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/boatinstrument.json');

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
