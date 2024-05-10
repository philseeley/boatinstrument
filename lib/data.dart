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

abstract class BoxSettings {}

abstract class BoxWidget extends StatefulWidget {
  const BoxWidget({super.key});

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
  final BoatInstrumentController _controller;

  const BlankBox(this._controller, {super.key});

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
    widget._controller.configure(widget.id, widget, null, { });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WidgetDetails {
  final String id;
  final String description;
  final BoxWidget Function(BoatInstrumentController) build;

  WidgetDetails(this.id, this.description, this.build);
}

//TODO widget for web page.
List<WidgetDetails> widgetDetails = [
  WidgetDetails(BlankBox.sid, 'Blank', (controller) {return BlankBox(controller, key: UniqueKey());}), // This is the default Box.
  WidgetDetails(DepthBox.sid, 'Depth', (controller) {return DepthBox(controller, key: UniqueKey());}),
  WidgetDetails(SpeedBox.sid, 'Speed', (controller) {return SpeedBox(controller, key: UniqueKey());}),
  WidgetDetails(SpeedOverGroundBox.sid, 'Speed Over Ground', (controller) {return SpeedOverGroundBox(controller, key: UniqueKey());}),
  WidgetDetails(WindSpeedApparentBox.sid, 'Wind Speed Apparent', (controller) {return WindSpeedApparentBox(controller, key: UniqueKey());}),
  WidgetDetails(WindSpeedTrueBox.sid, 'Wind Speed True', (controller) {return WindSpeedTrueBox(controller, key: UniqueKey());}),
  WidgetDetails(AutoPilotStatusBox.sid, 'Autopilot Status', (controller) {return AutoPilotStatusBox(controller, key: UniqueKey());}),
  WidgetDetails(AutoPilotControlBox.sid, 'Autopilot Control', (controller) {return AutoPilotControlBox(controller, key: UniqueKey());}),
];

WidgetDetails getWidgetDetails(BoatInstrumentController controller, String id) {
  for(WidgetDetails wd in widgetDetails) {
    if(wd.id == id) {
      return wd;
    }
  }

  controller.l.e('Unknown widget with ID $id', error: Exception('Unknown widget with ID $id'));
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

@JsonSerializable()
class _Settings {
  int version;
  int valueSmoothing;
  String signalkServer;
  bool wrapPages;
  DistanceUnits distanceUnits;
  SpeedUnits speedUnits;
  SpeedUnits windSpeedUnits;
  DepthUnits depthUnits;
  late List<_Page> pages;
  late Map<String, dynamic> widgetSettings;

  static File? _store;

  _Settings({
    this.version = 0,
    this.valueSmoothing = 1,
    this.signalkServer = 'openplotter.local:3000',
    this.wrapPages = true,
    this.distanceUnits = DistanceUnits.nm,
    this.speedUnits = SpeedUnits.kts,
    this.windSpeedUnits = SpeedUnits.kts,
    this.depthUnits = DepthUnits.m,
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

  static load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    String? s = _store?.readAsStringSync();
    dynamic data = json.decode(s ?? "");

    return _Settings.fromJson(data);
  }

  _save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}
