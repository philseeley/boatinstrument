part of 'boatinstrument_controller.dart';

const String degreesUnits = 'deg';
const double kelvinOffset = 273.15;

int rad2Deg(double? rad) => ((rad??0) * vm.radians2Degrees).round();
double deg2Rad(int? deg) => (deg??0) * vm.degrees2Radians;
String val2PS(num val) => val < 0 ? 'P' : (val > 0) ? 'S' : '';
double revolutions2RPM(double rev) => rev * 60;
double rpm2Revolutions(double rpm) => rpm / 60;
double kts2ms(double kts) => kts / 1.943844;
double ms2kts(double kts) => kts * 1.943844;
double millibar2pascal (double millibar) => millibar / 0.01;
double nm2m (double nm) => nm / 0.000539957;
double m2nm (double m) => m * 0.000539957;

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

  // Make sure the font is at least readable, even if this overflows.
  return fontSize>10.0?fontSize:10.0;
}

String dynamic2String(dynamic d) {
  StringBuffer s = StringBuffer();

  _dynamic2String(d, s);

  return s.toString();
}

void _dynamic2String(dynamic d, StringBuffer s) {

  if(({String, bool, int, double}).contains(d.runtimeType)) {
    s.write(d);
  } else {
    if(d['value'] != null) {
      _dynamic2String(d['value'], s);
    } else {
      for(String k in d.keys) {
        s.write('$k: ${d[k]} ');
      }
    }
  }
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

  void _paths(String path, Map<String, dynamic> data, bool add, List<String> paths) {
    if(add) {
      paths.add(path);
    }
    for (String k in data.keys) {
      if(!{r'meta', r'value', r'$source', r'timestamp', r'pgn'}.contains(k)) {
        try {
          if(data[k].runtimeType == String) {
            paths.add('$path${path.isEmpty?'':'.'}$k');
          } else {
            _paths('$path${path.isEmpty?'':'.'}$k', data[k], data[k]['value'] != null, paths);
          }
        } catch (e) {
          widget._controller.l.e('Walking path tree', error: e);
        }
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

      http.Response response = await widget._controller.httpGet(
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
            _paths(widget._basePath, data, true, paths);
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

abstract class EnumMenuEntry {
  String get displayName;
}

class EnumDropdownMenu<T extends EnumMenuEntry> extends DropdownMenu<T> {
  EnumDropdownMenu(List<T> entries, T? initialSelection, ValueChanged<T?> onSelected, {super.key}) :
    super(
      expandedInsets: EdgeInsets.zero,
      initialSelection: initialSelection,
      onSelected: onSelected,
      dropdownMenuEntries: entries.map((v) {
        return DropdownMenuEntry<T>(
              label: v.displayName,
              value: v,
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
            );
      }).toList()
    );
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

  Future<void> _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _HelpPage();
         })
    );
  }
}

class BoxDetails {
  final String id;
  final bool gauge;
  final bool graph;
  final bool experimental;
  final BoxWidget Function(BoxWidgetConfig config) build;
  final void Function(BoatInstrumentController controller)? background;

  BoxDetails(this.id, this.build, {this.gauge = false, this.graph = false, this.experimental = false, this.background});
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

enum DistanceUnits implements EnumMenuEntry {
  meters('Meters', 'm'),
  km('Kilometers', 'km'),
  miles('Miles', 'mile'),
  nm('Nautical Miles', 'nm'),
  nmM('Nautical Miles/Meters', 'nm');

  @override
  String get displayName => _displayName;

  final String _displayName;
  final String unit;

  const DistanceUnits(this._displayName, this.unit);
}

enum SpeedUnits implements EnumMenuEntry {
  mps('M/S', 'm/s'),
  kph('KPH', 'km/h'),
  mph('MPH', 'mph'),
  kts('Knots', 'kts');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const SpeedUnits(this._displayName, this.unit);
}

enum DepthUnits implements EnumMenuEntry {
  m('Meters', 'm'),
  ft('Feet', 'ft'),
  fa('Fathom', 'Fa');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const DepthUnits(this._displayName, this.unit);
}

enum TemperatureUnits implements EnumMenuEntry {
  c('Centigrade', 'C'),
  f('Fahrenheit', 'F'),
  k('Kelvin', 'K');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const TemperatureUnits(this._displayName, this.unit);
}

enum AirPressureUnits implements EnumMenuEntry {
  pascal('Pascal', 'Pa'),
  millibar('Millibars', 'mb'),
  atmosphere('Atmosphere', 'Atm'),
  mercury('MM Mercury', 'mmHg');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const AirPressureUnits(this._displayName, this.unit);
}

enum OilPressureUnits implements EnumMenuEntry {
  psi('Pounds/Sq Inch', 'Psi'),
  kpa('Kilopascal', 'kPa');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const OilPressureUnits(this._displayName, this.unit);
}

enum CapacityUnits implements EnumMenuEntry {
  liter('Liter', 'L'),
  gallon('Gallon', 'gal'),
  usGallon('US Gallon', 'US gal');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const CapacityUnits(this._displayName, this.unit);
}

enum FluidRateUnits implements EnumMenuEntry {
  litersPerHour('Liters per Hour', 'L/h'),
  gallonsPerHour('Gallons per Hour', 'gal/h'),
  usGallonsPerHour('US Gallons per Hour', 'US gal/h');

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String unit;

  const FluidRateUnits(this._displayName, this.unit);
}

enum PortStarboardColors implements EnumMenuEntry {
  none('None', Colors.black, Colors.white), // These are just placeholders and not used.
  redGreen('Red/Green', Colors.red, Colors.green),
  redBlue('Red/Blue', Colors.red, Colors.blue),
  orangeYellow('Orange/Yellow', Colors.orange, Colors.yellow);

  @override
  String get displayName => _displayName;
  final String _displayName;
  final Color portColor;
  final Color starboardColor;

  const PortStarboardColors(this._displayName, this.portColor, this.starboardColor);
}

enum DoubleValueToDisplay implements EnumMenuEntry {
  value('Value', ''),
  minimumValue('Minimum', 'Min '),
  maximumValue('Maximum', 'Max ');

  @override
  String get displayName => _displayName;

  final String _displayName;
  final String title;

  const DoubleValueToDisplay(this._displayName, this.title);
}

@JsonSerializable()
class _HttpHeader {
  String name;
  String value;

  _HttpHeader({
    this.name = '',
    this.value = ''});

  factory _HttpHeader.fromJson(Map<String, dynamic> json) =>
      _$HttpHeaderFromJson(json);

  Map<String, dynamic> toJson() => _$HttpHeaderToJson(this);
}

@JsonSerializable()
class _Settings {
  int version;
  int valueSmoothing;
  bool discoverServer;
  String signalkUrl;
  late List<_HttpHeader> httpHeaders;
  int signalkMinPeriod;
  int signalkConnectionTimeout;
  int dataTimeout;
  int notificationMuteTimeout; //Minutes
  bool demoMode;
  bool darkMode;
  bool wrapPages;
  bool brightnessControl;
  bool keepAwake;
  bool autoConfirmActions;
  bool pageTimerOnStart;
  bool enableExperimentalBoxes;
  bool setTime;
  DistanceUnits distanceUnits;
  int m2nmThreshold;
  SpeedUnits speedUnits;
  SpeedUnits windSpeedUnits;
  DepthUnits depthUnits;
  TemperatureUnits temperatureUnits;
  AirPressureUnits airPressureUnits;
  OilPressureUnits oilPressureUnits;
  CapacityUnits capacityUnits;
  FluidRateUnits fluidRateUnits;
  PortStarboardColors portStarboardColors;
  late List<_Page> pages;
  late Map<String, dynamic> boxSettings;

  static File? _store;

  String get fileName => _store!.absolute.path;

  _Settings({
    this.version = 1,
    this.valueSmoothing = 1,
    this.discoverServer = true,
    this.signalkUrl = '',
    this.httpHeaders = const [],
    this.signalkMinPeriod = 500,
    this.signalkConnectionTimeout = 20000,
    this.dataTimeout = 10000,
    this.notificationMuteTimeout = 15,
    this.demoMode = false,
    this.darkMode = true,
    this.wrapPages = true,
    this.brightnessControl = false,
    this.keepAwake = false,
    this.autoConfirmActions = false,
    this.pageTimerOnStart = false,
    this.enableExperimentalBoxes = false,
    this.setTime = false,
    this.distanceUnits = DistanceUnits.nm,
    this.m2nmThreshold = 500,
    this.speedUnits = SpeedUnits.kts,
    this.windSpeedUnits = SpeedUnits.kts,
    this.depthUnits = DepthUnits.m,
    this.temperatureUnits = TemperatureUnits.c,
    this.airPressureUnits = AirPressureUnits.millibar,
    this.oilPressureUnits = OilPressureUnits.kpa,
    this.capacityUnits = CapacityUnits.liter,
    this.fluidRateUnits = FluidRateUnits.litersPerHour,
    this.portStarboardColors = PortStarboardColors.redGreen,
    this.pages = const [],
    widgetSettings
  }) : boxSettings = widgetSettings??{} {
    if(pages.isEmpty) {
      pages = [_Page._newPage()];
    }
    if(httpHeaders.isEmpty) httpHeaders = [];
  }

  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Future<_Settings> load(String configFile) async {
    if(configFile.startsWith('/')) {
      _store = File(configFile);
    } else {
      Directory directory = await path_provider.getApplicationDocumentsDirectory();
      _store = File('${directory.path}/$configFile');
    }

    return await readSettings(_store!);
  }

  static Future<_Settings> readSettings(File f) async {
    var l =  CircularLogger();

    _Settings settings;

    try {
      String s = f.readAsStringSync();
      dynamic data = json.decode(s);

      if(data['version'] == 0) {
        l.i('Backing up configuration file');
        f.copy('${f.path}.v0');
        l.i('Converting configuration from version 0 to 1');
        String h = data['signalkHost'];
        String url = 'http://$h:${data['signalkPort']}';
        if(h.isEmpty) url = '';
        data['signalkUrl'] = url;
      data['version'] = 1;
      }

      settings =_Settings.fromJson(data);
    } catch (e) {
      var backupPath = '${f.path}.bad.${DateTime.now()}';
      l.e('Failed to decode config. Backing up to $backupPath', error: e);
      f.copy(backupPath);

      rethrow;
    }
    return settings;
  }

  void _save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}

enum GaugeOrientation {
  down(0, 0.0, -0.5, null, 0, 0, null, null, 0, null, 0),
  left(m.pi/2, 0.0, 0.0, 0, null, 0, null, null, 0, 0, null),
  up(m.pi, 0.0, 0.0, 0, null, 0, null, 0, null, null, 0),
  right(m.pi/2+m.pi, -0.5, 0.0, 0, null, null, 0, null, 0, null, 0);

  final double rotation;
  final double xm;
  final double ym;
  final double? titleTop;
  final double? titleBottom;
  final double? titleLeft;
  final double? titleRight;
  final double? unitsTop;
  final double? unitsBottom;
  final double? unitsLeft;
  final double? unitsRight;

  const GaugeOrientation(this.rotation, this.xm, this.ym,
      this.titleTop, this.titleBottom, this.titleLeft, this.titleRight,
      this.unitsTop, this.unitsBottom, this.unitsLeft, this.unitsRight);
}

class DataPoint {
  final DateTime date;
  final double value;

  DataPoint(this.date, this.value);
}

enum BackgroundDataDuration implements EnumMenuEntry {
  thirtyMinutes('30 Minutes', 30),
  oneHour('1 Hour', 1*60),
  twoHours('2 Hours', 2*60),
  fourHours('4 Hours', 4*60),
  sixHours('6 Hours', 6*60),
  twelveHours('12 Hours', 12*60),
  oneDay('1 Day', 24*60);

  @override
  String get displayName => _displayName;

  final String _displayName;
  final int minutes;

  const BackgroundDataDuration(this._displayName, this.minutes);
}

@JsonSerializable()
class BackgroundDataSettings {
  BackgroundDataDuration dataDuration;

  BackgroundDataSettings({this.dataDuration = BackgroundDataDuration.thirtyMinutes});
}

typedef BackgroundDataBuffer = CircularBuffer<DataPoint>;

abstract class BackgroundData {
  static const int dataIncrement = 1000;
  static final Map<String, BackgroundDataBuffer> dataBuffers = {};
  static final Map<String, double?> values = {};

  String id;
  BoatInstrumentController? controller;
  late Duration duration;
  double? minValue;
  double? maxValue;
  bool smoothing;

  BackgroundData(this.id, Set<String> paths, {this.controller, this.smoothing = true, this.minValue, this.maxValue}) {
    if(controller != null) {
      duration = Duration(minutes: _$BackgroundDataSettingsFromJson(controller!.getBoxSettingsJson(id)).dataDuration.minutes);

      controller!.configure(onUpdate: processUpdates, paths: paths, isBox: false);
    }
  }

  BackgroundDataBuffer get data => dataBuffers.putIfAbsent(id, () => CircularBuffer(BackgroundData.dataIncrement));
  set data(BackgroundDataBuffer data) => dataBuffers[id] = data;

  double? get value => values[id];
  set value(double? value) => values[id] = value;

  void processUpdates(List<Update>? updates) {
    if(updates != null) {
      try {
        double next =(updates[0].value as num).toDouble();

        if ((minValue == null || next >= minValue!) &&
            (maxValue == null || next <= maxValue!)) {
          if(smoothing) {
            value = averageDouble(value??next, next,
                smooth: controller!.valueSmoothing);
          } else {
            value = next;
          }
          DateTime now = DateTime.now();
          if(data.isNotEmpty && data.first.date.isAfter(now.subtract(duration)) && data.length/data.capacity > 0.8) {
            data = CircularBuffer<DataPoint>.of(data, data.capacity+dataIncrement);
          }
          data.add(DataPoint(now, value!));
        }
      } catch (e) {
        controller!.l.e("Error converting $updates", error: e);
      }
    }
  }
}

class BackgroundDataSettingsWidget extends BoxSettingsWidget {
  late final BackgroundDataSettings _settings;

  BackgroundDataSettingsWidget(Map<String, dynamic> json, {super.key}) {
    _settings = _$BackgroundDataSettingsFromJson(json);
  }

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$BackgroundDataSettingsToJson(_settings);
  }

  @override
  createState() => _BackgroundDataSettingsState();
}

class _BackgroundDataSettingsState extends State<BackgroundDataSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    BackgroundDataSettings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text("Data Duration:"),
          title: EnumDropdownMenu(
            BackgroundDataDuration.values,
            s.dataDuration,
            (v) {
              setState(() {
                s.dataDuration = v!;
              });
            })
      ),
    ]);
  }
}

mixin DoubleValeBoxPainter {
  static const double _pad = 5.0;

  void paintDoubleBox(Canvas canvas, BuildContext context, String title, String units, int minLen, int precision, double? value, Offset loc, double size) {
    Color fg = Theme.of(context).colorScheme.onSurface;
    Color bg = Theme.of(context).colorScheme.surface;
    TextStyle style = Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.0);

    String speedText = '-';
    if(value != null) speedText = fmt.format('{:${minLen+(precision > 0?1:0)+precision}.${precision}f}', value);

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = bg
      ..strokeWidth = 2.0;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(loc, loc+Offset(size, size)), const Radius.circular(10)), paint);
    paint..style = PaintingStyle.stroke
      ..color = fg;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(loc, loc+Offset(size, size)), const Radius.circular(10)), paint);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      double fontSize = maxFontSize(speedText, style, size-(2*_pad), size-style.fontSize!-(3*_pad));

      tp.text = TextSpan(
          text: '$title $units',
          style: style);
      tp.layout();
      tp.paint(canvas, loc+const Offset(_pad,_pad));

      tp.text = TextSpan(
          text: speedText,
          style: style.copyWith(fontSize: fontSize));
      tp.layout();
      Offset o = loc+Offset(_pad, size-fontSize-_pad);
      tp.paint(canvas, o);
    } finally {
      tp.dispose();
    }
  }
}
