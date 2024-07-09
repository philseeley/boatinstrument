part of 'boatinstrument_controller.dart';

int rad2Deg(double? rad) => ((rad??0) * vm.radians2Degrees).round();
double deg2Rad(int? deg) => (deg??0) * vm.degrees2Radians;
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
  //TODO Haven't worked out why the "- 1.0" is required.
  double fontSize = availableHeight - 1.0;
  // The size must be greater than 0 to avoid rendering errors.
  fontSize = (fontSize > 0.0) ? fontSize : 1.0;

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

double convertDistance(BoatInstrumentController controller, double distance) {
  switch (controller.distanceUnits) {
    case DistanceUnits.meters:
      return distance;
    case DistanceUnits.km:
      return distance * 0.001;
    case DistanceUnits.miles:
      return distance * 0.000621371;
    case DistanceUnits.nm:
      return distance * 0.000539957;
    case DistanceUnits.nmM:
      if(distance <= controller.m2nmThreshold) {
        return distance;
      } else {
        return distance * 0.000539957;
      }
  }
}

String distanceUnits(BoatInstrumentController controller, double distance) {
  if(controller.distanceUnits == DistanceUnits.nmM &&
      distance.abs() <= controller.m2nmThreshold) {
    return 'm';
  }
  return controller.distanceUnits.unit;
}

double convertSpeed(SpeedUnits units, double speed) {
  switch (units) {
    case SpeedUnits.mps:
      return speed;
    case SpeedUnits.kph:
      return speed * 3.6;
    case SpeedUnits.mph:
      return speed * 2.236936;
    case SpeedUnits.kts:
      return speed * 1.943844;
  }
}

class BoxWidgetConfig {
  final BoatInstrumentController controller;
  final Map<String, dynamic> settings;
  final BoxConstraints constraints;
  final bool editMode;

  BoxWidgetConfig(this.controller, this.settings, this.constraints, this.editMode);
}

abstract class BoxWidget extends StatefulWidget {
  final BoxWidgetConfig config;

  const BoxWidget(this.config, {super.key});

  // This should be overridden to return a static and unique string.
  // The static string is used to identify the Box class prior to instantiation.
  // e.g.
  //   static String sid = 'my-value';
  //   @override
  //   String get id => sid;
  String get id;

  // Set if the Box has settings common to all Boxes of this type.
  bool get hasSettings => false;

  // Should return a Widget tree for configuring the Settings.
  // This would normally be a ListView.
  BoxSettingsWidget? getSettingsWidget(Map<String, dynamic> json) {
    return null;
  }

  // Set if the Box has instance settings.
  bool get hasPerBoxSettings => false;

  // Should return a Widget tree for configuring the Settings.
  // This would normally be a ListView.
  BoxSettingsWidget? getPerBoxSettingsWidget() {
    return null;
  }

  // If the Settings are not obvious, these should return help Widgets.
  // This would normally be a simple Text Widget.
  Widget? getSettingsHelp() => null;
  Widget? getPerBoxSettingsHelp() => null;
}

abstract class BoxSettingsWidget extends StatefulWidget {
  const BoxSettingsWidget({super.key});

  // Should return the Settings as a JSON map.
  Map<String, dynamic> getSettingsJson();
}

class BlankBox extends BoxWidget {

  const BlankBox(super.config, {super.key});

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
    widget.config.controller.configure(widget);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HelpBox extends BoxWidget {

  const HelpBox(super.config, {super.key});

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
    widget.config.controller.configure(widget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(40.0), alignment: Alignment.topCenter, child: IconButton(icon: const Icon(Icons.help), iconSize: 80.0, onPressed: _showHelpPage));
  }

  _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _HelpPage(widget.config.controller);
         })
    );
  }
}

class BoxDetails {
  final String id;
  final String description;
  final BoxWidget Function(BoxWidgetConfig config) build;

  BoxDetails(this.id, this.description, this.build);
}

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

typedef OnUpdate = Function(List<Update>? updates);

class _WidgetData {
  Widget widget;
  bool configured = false;
  DateTime lastUpdate = DateTime.now();
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
class _Box extends _Resizable {
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
class _Row extends _Resizable {
  List<_Box> boxes;

  _Row(this.boxes, super.percentage);

  factory _Row.fromJson(Map<String, dynamic> json) =>
      _$RowFromJson(json);

  Map<String, dynamic> toJson() => _$RowToJson(this);
}

@JsonSerializable()
class _Column extends _Resizable {
  List<_Row> rows;

  _Column(this.rows, super.percentage);

  factory _Column.fromJson(Map<String, dynamic> json) =>
      _$ColumnFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnToJson(this);
}

@JsonSerializable()
class _PageRow extends _Resizable {
  List<_Column> columns;

  _PageRow(this.columns, super.percentage);

  factory _PageRow.fromJson(Map<String, dynamic> json) =>
      _$PageRowFromJson(json);

  Map<String, dynamic> toJson() => _$PageRowToJson(this);
}

@JsonSerializable()
class _Page {
  String name;
  List<_PageRow> pageRows;

  _Page(this.name, this.pageRows);

  factory _Page.fromJson(Map<String, dynamic> json) =>
      _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);

  static _Page _newPage() => _Page('Page Name', [_PageRow([_Column([_Row([_Box.help()], 1)], 1)], 1)]);

  _Page clone() {
    _Page clone = _Page('$name - copy', []);

    for(_PageRow pr in pageRows) {
      _PageRow epr = _PageRow([], pr.percentage);
      clone.pageRows.add(epr);
      for (_Column c in pr.columns) {
        _Column ec = _Column([], c.percentage);
        epr.columns.add(ec);
        for (_Row r in c.rows) {
          _Row er = _Row([], r.percentage);
          ec.rows.add(er);
          for (_Box b in r.boxes) {
            er.boxes.add(_Box(b.id, b.settings, b.percentage));
          }
        }
      }
    }

    return clone;
  }
}

enum DistanceUnits {
  meters('Meters', 'm'),
  km('Kilometers', 'km'),
  miles('Miles', 'mile'),
  nm('Nautical Miles', 'nm'),
  nmM('Nautical Miles/Meters', 'nm');

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
  int signalkMinPeriod;
  int signalkConnectionTimeout;
  int dataTimeout;
  bool darkMode;
  bool wrapPages;
  bool brightnessControl;
  bool keepAwake;
  bool autoConfirmActions;
  DistanceUnits distanceUnits;
  int m2nmThreshold;
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
    this.signalkMinPeriod = 500,
    this.signalkConnectionTimeout = 20000,
    this.dataTimeout = 10000,
    this.darkMode = true,
    this.wrapPages = true,
    this.brightnessControl = false,
    this.keepAwake = false,
    this.autoConfirmActions = false,
    this.distanceUnits = DistanceUnits.nm,
    this.m2nmThreshold = 500,
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
