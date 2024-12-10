part of 'boatinstrument_controller.dart';

const String degreesUnits = 'deg';
const double kelvinOffset = 273.15;

int rad2Deg(double? rad) => ((rad??0) * vm.radians2Degrees).round();
double deg2Rad(int? deg) => (deg??0) * vm.degrees2Radians;
String val2PS(num val) => val < 0 ? 'P' : (val > 0) ? 'S' : '';
double revolutions2RPM(double rev) => rev * 60;
double rpm2Revolutions(double rpm) => rpm / 60;

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
  try {
    // Check if we're constrained by width.
    if (textPainter.size.width > availableWidth) {
      fontSize = (fontSize * (availableWidth / textPainter.size.width)) - 1.0;
    }
  } finally {
    textPainter.dispose();
  }

  return fontSize;
}

class SignalkPathDropdownMenu extends StatefulWidget {
  final BoatInstrumentController _controller;
  final String _initialValue;
  final String _basePath;
  final ValueChanged<String> _onSelected;
  final bool listPaths;
  final bool searchable;

  const SignalkPathDropdownMenu(this._controller, this._initialValue, this._basePath, this._onSelected,
    {this.listPaths = false, this.searchable = false, super.key});

  @override
  State<StatefulWidget> createState() => _SignalkPathDropdownMenuState();
}

class _SignalkPathDropdownMenuState extends State<SignalkPathDropdownMenu> {
  List<String> values = [];

  @override
  void initState() {
    super.initState();
    getPaths();
  }

  _paths(String path, Map<String, dynamic> data, List<String> paths) {
    paths.add(path);
    for (String k in data.keys) {
      if({'meta', 'value', '\$source', 'timestamp', 'pgn'}.contains(k)) {
        return;
      }
      try {
        if(data[k].runtimeType == String) {
          paths.add(k);
        } else {
          _paths('$path${path.isEmpty?'':'.'}$k', data[k], paths);
        }
      } catch (e) {
        widget._controller.l.e('Walking path tree', error: e);
      }
    }
  }

  void getPaths() async {
    Uri uri = widget._controller.httpApiUri;

    try {

      List<String> ps = [...uri.pathSegments]
        ..removeLast()
        ..addAll(['vessels', 'self'])
        ..addAll(widget._basePath.split('.'));

      uri = uri.replace(pathSegments: ps);

      http.Response response = await http.get(
          uri,
          headers: {
            "accept": "application/json",
          },
      );

      if(response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          if(widget.listPaths) {
            List<String> paths = [];
            _paths(widget._basePath, data, paths);
            values.addAll(paths);
          } else {
            values.addAll(data.keys);
          }
        });
      } else {
        setState(() {
          values.add('');
        });
      }
    } catch (e) {
      widget._controller.l.e('Failed to retrieve metadata', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(values.isEmpty) {
      return const Text('Waiting for SignalK');
    }

    String iv = widget._initialValue;

    if(widget._initialValue.isEmpty) {
       iv = values.firstOrNull??'';
       widget._onSelected(iv);
    }

    DropdownMenu menu = DropdownMenu<String>(
      expandedInsets: EdgeInsets.zero,
      enableSearch: false,
      enableFilter: widget.searchable,
      requestFocusOnTap: widget.searchable,
      initialSelection: iv,
      dropdownMenuEntries: values.map<DropdownMenuEntry<String>>((String v) {return DropdownMenuEntry<String>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
          value: v,
          label: v);}).toList(),
      onSelected: (value) {
        widget._onSelected(value??'');
      },
    );

    return menu;
  }
}

class BoxWidgetConfig {
  final BoatInstrumentController controller;
  final Map<String, dynamic> settings;
  final BoxConstraints constraints;
  final bool editMode;

  BoxWidgetConfig(this.controller, this.settings, this.constraints, this.editMode);
}

class HelpTextWidget extends StatelessWidget {
  final String _text;

  const HelpTextWidget(this._text, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [ListTile(title: Text(_text))],);
  }
}

abstract class BoxWidget extends StatefulWidget {
  final BoxWidgetConfig config;

  const BoxWidget(this.config, {super.key});

  // This should be overridden to return a static and unique string.
  // The static string is used to identify the Box class prior to instantiation.
  // e.g.
  //   static const String sid = 'my-value';
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

  // Provide any non-obvious help for the Box or its Settings. This could be a
  // ListView with Icons, but for a simple text String you can wrap this in a
  // HelpTextWidget:
  // e.g.
  //   @override
  //    Widget? getHelp(BuildContext context) => const HelpTextWidget('My simple help.');
  Widget? getHelp(BuildContext context) => null;

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
    widget.config.controller.configure();
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
    widget.config.controller.configure();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Press for Help'), const Icon(Icons.east), IconButton(icon: const Icon(Icons.help), iconSize: 80.0, onPressed: _showHelpPage)]),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Swipe down'), Icon(Icons.south), Text('to setup pages\nand configure')])
    ]);
  }

  _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _HelpPage();
         })
    );
  }
}

class BoxDetails {
  final String id;
  final String description;
  final bool gauge;
  final BoxWidget Function(BoxWidgetConfig config) build;

  BoxDetails(this.id, this.description, this.gauge, this.build);
}

BoxDetails getBoxDetails(String id) {
  for(BoxDetails bd in boxDetails) {
    if(bd.id == id) {
      return bd;
    }
  }

  CircularLogger().e('Unknown widget with ID $id', error: Exception('Unknown widget with ID $id'));
  return boxDetails[0];
}

class Update {
  final String path;
  final dynamic value;

  Update(this.path, this.value);

  @override
  String toString() {
    return 'path: $path, value: $value';
  }
}

typedef OnUpdate = Function(List<Update>? updates);

class _BoxData {
  final OnUpdate? onUpdate;
  final Set<String> paths;
  final OnUpdate? onStaticUpdate;
  final Set<String> staticPaths;
  final bool dataTimeout;
  List<RegExp> regExpPaths = [];
  List<RegExp> regExpStaticPaths = [];
  DateTime lastUpdate = DateTime.now();
  List<Update> updates = [];
  List<Update> staticUpdates = [];

  _BoxData(this.onUpdate, this.paths, this.onStaticUpdate, this.staticPaths, this.dataTimeout);
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
  int? timeout;
  List<_PageRow> pageRows;

  _Page(this.name, this.timeout, this.pageRows);

  factory _Page.fromJson(Map<String, dynamic> json) =>
      _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);

  static _Page _newPage() => _Page('Page Name', null, [_PageRow([_Column([_Row([_Box.help()], 1)], 1)], 1)]);

  _Page clone() {
    _Page clone = _Page('$name - copy', null, []);

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

enum AirPressureUnits {
  pascal('Pascal', 'Pa'),
  millibar('Millibars', 'mb'),
  atmosphere('Atmosphere', 'Atm'),
  mercury('MM Mercury', 'mmHg');

  final String displayName;
  final String unit;

  const AirPressureUnits(this.displayName, this.unit);
}

enum OilPressureUnits {
  psi('Pounds/Sq Inch', 'Psi'),
  kpa('Kilopascal', 'kPa');

  final String displayName;
  final String unit;

  const OilPressureUnits(this.displayName, this.unit);
}

enum CapacityUnits {
  liter('Liter', 'L'),
  gallon('Gallon', 'gal'),
  usGallon('US Gallon', 'US gal');

  final String displayName;
  final String unit;

  const CapacityUnits(this.displayName, this.unit);
}

enum PortStarboardColors {
  none('None', Colors.black, Colors.white), // These are just placeholders and not used.
  redGreen('Red/Green', Colors.red, Colors.green),
  redBlue('Red/Blue', Colors.red, Colors.blue),
  orangeYellow('Orange/Yellow', Colors.orange, Colors.yellow);

  final String displayName;
  final Color portColor;
  final Color starboardColor;

  const PortStarboardColors(this.displayName, this.portColor, this.starboardColor);
}

@JsonSerializable()
class _Settings {
  int version;
  int valueSmoothing;
  bool discoverServer;
  String signalkHost;
  int signalkPort;
  int signalkMinPeriod;
  int signalkConnectionTimeout;
  int dataTimeout;
  bool demoMode;
  bool darkMode;
  bool wrapPages;
  bool brightnessControl;
  bool keepAwake;
  bool autoConfirmActions;
  bool pageTimerOnStart;
  DistanceUnits distanceUnits;
  int m2nmThreshold;
  SpeedUnits speedUnits;
  SpeedUnits windSpeedUnits;
  DepthUnits depthUnits;
  TemperatureUnits temperatureUnits;
  AirPressureUnits airPressureUnits;
  OilPressureUnits oilPressureUnits;
  CapacityUnits capacityUnits;
  PortStarboardColors portStarboardColors;
  late List<_Page> pages;
  late Map<String, dynamic> boxSettings;

  static File? _store;

  String get fileName => _store!.absolute.path;

  _Settings({
    this.version = 0,
    this.valueSmoothing = 1,
    this.discoverServer = true,
    this.signalkHost = '',
    this.signalkPort = 3000,
    this.signalkMinPeriod = 500,
    this.signalkConnectionTimeout = 20000,
    this.dataTimeout = 10000,
    this.demoMode = false,
    this.darkMode = true,
    this.wrapPages = true,
    this.brightnessControl = false,
    this.keepAwake = false,
    this.autoConfirmActions = false,
    this.pageTimerOnStart = false,
    this.distanceUnits = DistanceUnits.nm,
    this.m2nmThreshold = 500,
    this.speedUnits = SpeedUnits.kts,
    this.windSpeedUnits = SpeedUnits.kts,
    this.depthUnits = DepthUnits.m,
    this.temperatureUnits = TemperatureUnits.c,
    this.airPressureUnits = AirPressureUnits.millibar,
    this.oilPressureUnits = OilPressureUnits.kpa,
    this.capacityUnits = CapacityUnits.liter,
    this.portStarboardColors = PortStarboardColors.redGreen,
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
