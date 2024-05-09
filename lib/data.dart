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

class WidgetDetails {
  final String id;
  final String description;
  final BoxWidget Function(BoatInstrumentController) build;

  WidgetDetails(this.id, this.description, this.build);
}

//TODO need to have proper IDs for the other DoubleValueDisplay entries.
//TODO widget for web page.
List<WidgetDetails> widgetDetails = [
  WidgetDetails('depth', 'Depth', (controller) {return DoubleValueDisplay(controller, 'DPT', 'environment.depth.belowSurface', 'm', 1, key: UniqueKey());}),
  WidgetDetails('true-wind-speed', 'True Wind Speed', (controller) {return DoubleValueDisplay(controller, 'TWS', 'environment.wind.speedTrue', 'kts', 1, key: UniqueKey());}),
  WidgetDetails('apparent-wind-speed', 'Apparent Wind Speed', (controller) {return DoubleValueDisplay(controller, 'AWS', 'environment.wind.speedApparent', 'kts', 1, key: UniqueKey());}),
  WidgetDetails(AutoPilotDisplay.sid, 'Autopilot Display', (controller) {return AutoPilotDisplay(controller, key: UniqueKey());}),
  WidgetDetails(AutoPilotControl.sid, 'Autopilot Control', (controller) {return AutoPilotControl(controller, key: UniqueKey());}),
];

WidgetDetails getWidgetDetails(String id) {
  for(WidgetDetails wd in widgetDetails) {
    if(wd.id == id) {
      return wd;
    }
  }

  throw Exception('Unknown widget with ID $id');
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

@JsonSerializable()
class _Settings {
  int version;
  int valueSmoothing;
  String signalkServer;
  late List<_Page> pages;
  late Map<String, dynamic> widgetSettings;

  static File? _store;

  _Settings({
    this.version = 0,
    this.valueSmoothing = 1,
    this.signalkServer = 'openplotter.local:3000',
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
