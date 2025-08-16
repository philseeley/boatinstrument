part of 'boatinstrument_controller.dart';

class _EditPage extends StatefulWidget {
  final BoatInstrumentController _controller;
  final _Page _page;
  late final _Page _editPage;

  _EditPage(this._controller, this._page) {
    _editPage = _page.clone();
  }

  @override
  State<_EditPage> createState() => _EditPageState();
}
final List<BoxDetails> boxDetails = [
  BoxDetails(BlankBox.sid, (config) {return BlankBox(config, key: UniqueKey());}), // This is the default Box.
  BoxDetails(HelpBox.sid, (config) {return HelpBox(config, key: UniqueKey());}),
  BoxDetails(DepthBelowSurfaceBox.sid, (config) {return DepthBelowSurfaceBox(config, key: UniqueKey());}),
  BoxDetails(MinDepthBelowSurfaceBox.sid, (config) {return MinDepthBelowSurfaceBox(config, key: UniqueKey());}),
  BoxDetails(DepthBelowKeelBox.sid, (config) {return DepthBelowKeelBox(config, key: UniqueKey());}),
  BoxDetails(MinDepthBelowKeelBox.sid, (config) {return MinDepthBelowKeelBox(config, key: UniqueKey());}),
  BoxDetails(DepthBelowTransducerBox.sid, (config) {return DepthBelowTransducerBox(config, key: UniqueKey());}),
  BoxDetails(MinDepthBelowTransducerBox.sid, (config) {return MinDepthBelowTransducerBox(config, key: UniqueKey());}),
  BoxDetails(SpeedThroughWaterBox.sid, (config) {return SpeedThroughWaterBox(config, key: UniqueKey());}),
  BoxDetails(MaxSpeedThroughWaterBox.sid, (config) {return MaxSpeedThroughWaterBox(config, key: UniqueKey());}),
  BoxDetails(SpeedOverGroundBox.sid, (config) {return SpeedOverGroundBox(config, key: UniqueKey());}),
  BoxDetails(MaxSpeedOverGroundBox.sid, (config) {return MaxSpeedOverGroundBox(config, key: UniqueKey());}),
  BoxDetails(WindSpeedApparentBox.sid, (config) {return WindSpeedApparentBox(config, key: UniqueKey());}),
  BoxDetails(MaxWindSpeedApparentBox.sid, (config) {return MaxWindSpeedApparentBox(config, key: UniqueKey());}),
  BoxDetails(WindSpeedTrueBox.sid, (config) {return WindSpeedTrueBox(config, key: UniqueKey());}),
  BoxDetails(MaxWindSpeedTrueBox.sid, (config) {return MaxWindSpeedTrueBox(config, key: UniqueKey());}),
  BoxDetails(WindDirectionTrueBox.sid, (config) {return WindDirectionTrueBox(config, key: UniqueKey());}),
  BoxDetails(WindRoseBox.sid, gauge: true, (config) {return WindRoseBox(config, key: UniqueKey());}),
  BoxDetails(PositionBox.sid, (config) {return PositionBox(config, key: UniqueKey());}),
  BoxDetails(CourseOverGroundBox.sid, (config) {return CourseOverGroundBox(config, key: UniqueKey());}),
  BoxDetails(WaterTemperatureBox.sid, (config) {return WaterTemperatureBox(config, key: UniqueKey());}),
  BoxDetails(OutsideHumidityBox.sid, (config) {return OutsideHumidityBox(config, key: UniqueKey());}),
  BoxDetails(InsideHumidityBox.sid, (config) {return InsideHumidityBox(config, key: UniqueKey());}),
  BoxDetails(AutopilotStatusBox.sid, (config) {return AutopilotStatusBox(config, key: UniqueKey());}),
  BoxDetails(AutopilotStateControlHorizontalBox.sid, (config) {return AutopilotStateControlHorizontalBox(config, key: UniqueKey());}),
  BoxDetails(AutopilotStateControlVerticalBox.sid, (config) {return AutopilotStateControlVerticalBox(config, key: UniqueKey());}),
  BoxDetails(AutopilotHeadingControlHorizontalBox.sid, (config) {return AutopilotHeadingControlHorizontalBox(config, key: UniqueKey());}),
  BoxDetails(AutopilotHeadingControlVerticalBox.sid, (config) {return AutopilotHeadingControlVerticalBox(config, key: UniqueKey());}),
  BoxDetails(WebViewBox.sid, experimental: true, (config) {return WebViewBox(config, key: UniqueKey());}),
  BoxDetails(RudderAngleBox.sid, gauge: true, (config) {return RudderAngleBox(config, key: UniqueKey());}),
  BoxDetails(CustomTextBox.sid, (config) {return CustomTextBox(config, key: UniqueKey());}),
  BoxDetails(CustomDoubleValueBox.sid, (config) {return CustomDoubleValueBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(CustomDoubleValueSemiGaugeBox.sid, gauge: true, (config) {return CustomDoubleValueSemiGaugeBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(CustomDoubleValueCircularGaugeBox.sid, gauge: true, (config) {return CustomDoubleValueCircularGaugeBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(CustomDoubleValueBarGaugeBox.sid, gauge: true, (config) {return CustomDoubleValueBarGaugeBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(DateTimeBox.sid, (config) {return DateTimeBox(config, key: UniqueKey());}),
  BoxDetails(CrossTrackErrorBox.sid, (config) {return CrossTrackErrorBox(config, key: UniqueKey());}),
  BoxDetails(WindSpeedTrueBeaufortBox.sid, (config) {return WindSpeedTrueBeaufortBox(config, key: UniqueKey());}),
  BoxDetails(SetAndDriftBox.sid, (config) {return SetAndDriftBox(config, key: UniqueKey());}),
  BoxDetails(HeadingTrueBox.sid, (config) {return HeadingTrueBox(config, key: UniqueKey());}),
  BoxDetails(HeadingMagneticBox.sid, (config) {return HeadingMagneticBox(config, key: UniqueKey());}),
  BoxDetails(NextPointDistanceBox.sid, (config) {return NextPointDistanceBox(config, key: UniqueKey());}),
  BoxDetails(NextPointBearingBox.sid, (config) {return NextPointBearingBox(config, key: UniqueKey());}),
  BoxDetails(NextPointVelocityMadeGoodBox.sid, (config) {return NextPointVelocityMadeGoodBox(config, key: UniqueKey());}),
  BoxDetails(NextPointTimeToGoBox.sid, (config) {return NextPointTimeToGoBox(config, key: UniqueKey());}),
  // BoxDetails(RouteTimeToGoBox.sid, (config) {return RouteTimeToGoBox(config, key: UniqueKey());}),
  BoxDetails(AttitudeRollGaugeBox.sid, gauge: true, (config) {return AttitudeRollGaugeBox(config, key: UniqueKey());}),
  BoxDetails(CrossTrackErrorDeltaBox.sid, gauge: true, (config) {return CrossTrackErrorDeltaBox(config, key: UniqueKey());}),
  BoxDetails(WindAngleApparentBox.sid, (config) {return WindAngleApparentBox(config, key: UniqueKey());}),
  BoxDetails(MagneticVariationBox.sid, (config) {return MagneticVariationBox(config, key: UniqueKey());}),
  BoxDetails(OutsideTemperatureBox.sid, (config) {return OutsideTemperatureBox(config, key: UniqueKey());}),
  BoxDetails(OutsidePressureBox.sid, (config) {return OutsidePressureBox(config, key: UniqueKey());}),
  BoxDetails(SunlightBox.sid, (config) {return SunlightBox(config, key: UniqueKey());}),
  BoxDetails(MoonBox.sid, (config) {return MoonBox(config, key: UniqueKey());}),
  BoxDetails(DebugBox.sid, (config) {return DebugBox(config, key: UniqueKey());}),
  BoxDetails(AnchorAlarmBox.sid, gauge: true, (config) {return AnchorAlarmBox(config, key: UniqueKey());}),
  BoxDetails(BatteriesBox.sid, (config) {return BatteriesBox(config, key: UniqueKey());}),
  BoxDetails(BatteryVoltMeterBox.sid, gauge: true, (config) {return BatteryVoltMeterBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(BatteryVoltageBox.sid, (config) {return BatteryVoltageBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(BatteryCurrentBox.sid, (config) {return BatteryCurrentBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(BatteryTemperatureBox.sid, (config) {return BatteryTemperatureBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(InverterCurrentBox.sid, (config) {return InverterCurrentBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(SolarVoltageBox.sid, (config) {return SolarVoltageBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(SolarCurrentBox.sid, (config) {return SolarCurrentBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(EngineRPMBox.sid, gauge: true, (config) {return EngineRPMBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(EngineTempBox.sid, gauge: true, (config) {return EngineTempBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(EngineExhaustTempBox.sid, gauge: true, (config) {return EngineExhaustTempBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(EngineOilPressureBox.sid, gauge: true, (config) {return EngineOilPressureBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(EngineFuelRateBox.sid, (config) {return EngineFuelRateBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(TanksBox.sid, (config) {return TanksBox(config, key: UniqueKey());}),
  BoxDetails(FreshWaterTankBox.sid, gauge: true, (config) {return FreshWaterTankBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(GreyWaterTankBox.sid, gauge: true, (config) {return GreyWaterTankBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(BlackWaterTankBox.sid, gauge: true, (config) {return BlackWaterTankBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(FuelTankBox.sid, gauge: true, (config) {return FuelTankBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(LubricationTankBox.sid, gauge: true, (config) {return LubricationTankBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(RateOfTurnBox.sid, (config) {return RateOfTurnBox(config, key: UniqueKey());}),
  BoxDetails(ElectricalSwitchesBox.sid, experimental: true, (config) {return ElectricalSwitchesBox(config, key: UniqueKey());}),
  BoxDetails(ElectricalSwitchBox.sid, experimental: true, (config) {return ElectricalSwitchBox(config, key: UniqueKey());}),
  BoxDetails(TrueWindSpeedGraph.sid, graph: true, background: (ctrl) {TrueWindSpeedGraphBackground(controller: ctrl);}, (config) {return TrueWindSpeedGraph(config, key: UniqueKey());}),
  BoxDetails(ApparentWindSpeedGraph.sid, graph: true, background: (ctrl) {ApparentWindSpeedGraphBackground(controller: ctrl);}, (config) {return ApparentWindSpeedGraph(config, key: UniqueKey());}),
  BoxDetails(WaterTemperatureGraph.sid, graph: true, background: (ctrl) {WaterTemperatureGraphBackground(controller: ctrl);}, (config) {return WaterTemperatureGraph(config, key: UniqueKey());}),
  BoxDetails(SpeedThroughWaterGraph.sid, graph: true, background: (ctrl) {SpeedThroughWaterGraphBackground(controller: ctrl);}, (config) {return SpeedThroughWaterGraph(config, key: UniqueKey());}),
  BoxDetails(SpeedOverGroundGraph.sid, graph: true, background: (ctrl) {SpeedOverGroundGraphBackground(controller: ctrl);}, (config) {return SpeedOverGroundGraph(config, key: UniqueKey());}),
  BoxDetails(OutsidePressureGraph.sid, graph: true, background: (ctrl) {OutsidePressureGraphBackground(controller: ctrl);}, (config) {return OutsidePressureGraph(config, key: UniqueKey());}),
  BoxDetails(OutsideTemperatureGraph.sid, graph: true, background: (ctrl) {OutsideTemperatureGraphBackground(controller: ctrl);}, (config) {return OutsideTemperatureGraph(config, key: UniqueKey());}),
  BoxDetails(VNCBox.sid, experimental: true, (config) {return VNCBox(config, key: UniqueKey());}),
  BoxDetails(CrossTrackErrorGraph.sid, graph: true, background: (ctrl) {CrossTrackErrorGraphBackground(controller: ctrl);}, (config) {return CrossTrackErrorGraph(config, key: UniqueKey());}),
  BoxDetails(DepthBelowSurfaceGraph.sid, graph: true, background: (ctrl) {DepthBelowSurfaceGraphBackground(controller: ctrl);}, (config) {return DepthBelowSurfaceGraph(config, key: UniqueKey());}),
  BoxDetails(DepthBelowKeelGraph.sid, graph: true, background: (ctrl) {DepthBelowKeelGraphBackground(controller: ctrl);}, (config) {return DepthBelowKeelGraph(config, key: UniqueKey());}),
  BoxDetails(DepthBelowTransducerGraph.sid, graph: true, background: (ctrl) {DepthBelowTransducerGraphBackground(controller: ctrl);}, (config) {return DepthBelowTransducerGraph(config, key: UniqueKey());}),
  BoxDetails(RPiCPUTemperatureBox.sid, (config) {return RPiCPUTemperatureBox(config, key: UniqueKey());}),
  BoxDetails(RPiGPUTemperatureBox.sid, (config) {return RPiGPUTemperatureBox(config, key: UniqueKey());}),
  BoxDetails(RPiCPUUtilisationBox.sid, gauge: true, (config) {return RPiCPUUtilisationBox(config, key: UniqueKey());}),
  BoxDetails(RPiMemoryUtilisationBox.sid, gauge: true, (config) {return RPiMemoryUtilisationBox(config, key: UniqueKey());}),
  BoxDetails(RPiSDUtilisationBox.sid, gauge: true, (config) {return RPiSDUtilisationBox(config, key: UniqueKey());}),
  BoxDetails(RaspberryPiBox.sid, experimental: true, (config) {return RaspberryPiBox(config, key: UniqueKey());}),
  BoxDetails(BatteryPowerGraph.sid, graph: true, background: (ctrl) {BatteryPowerGraphBackground(controller: ctrl);}, (config) {return BatteryPowerGraph(config, key: UniqueKey());}),
  BoxDetails(SolarPowerGraph.sid, graph: true, background: (ctrl) {SolarPowerGraphBackground(controller: ctrl);}, (config) {return SolarPowerGraph(config, key: UniqueKey());}),
  BoxDetails(CompassRoseBox.sid, gauge: true, (config) {return CompassRoseBox(config, key: UniqueKey());}),
  BoxDetails(CompassGaugeBox.sid, gauge: true, (config) {return CompassGaugeBox(config, key: UniqueKey());}),
];

class _EditPageState extends State<_EditPage> {
  static const String _boxMenuName = '__BOX_MENU__';

  PopupMenuItem<BoxDetails> _widgetMenuEntry(String id, String text) {
    BoxDetails bd = getBoxDetails(id);
    List<Widget> c = [Text(text)];
    if(bd.gauge) {
      c.add(const Icon(Icons.speed));
    }
    if(bd.graph) {
      c.add(const Icon(Icons.show_chart));
    }
    if(bd.experimental) {
      c.add(const Icon(Icons.science_outlined));
    }

    return PopupMenuItem<BoxDetails>(enabled: !bd.experimental || widget._controller.enableExperimentalBoxes, height: 0, value: bd, child: Row(children: c));
  }

  PopupMenuItem<BoxDetails> _widgetSubMenuEntry(_Box box, String text, List<PopupMenuEntry<BoxDetails>> subMenuEntries) {
    return PopupMenuItem(height: 0, child: PopupMenuButton<BoxDetails>(
      tooltip: '',
      shape: Border.all(color: Colors.grey),
      itemBuilder: (context) {
        List<PopupMenuEntry<BoxDetails>> items = [
          PopupMenuItem<BoxDetails>(child: Row(children: [const Icon(Icons.arrow_left), Text(text, style: TextStyle(decoration: TextDecoration.underline))])),
          ...subMenuEntries
        ];
        return items;
      },
      onSelected: (value) {
        setState(() {
          box.id = value.id;
          box.settings = {};
          Navigator.of(context).popUntil((route) { return route.settings.name == _boxMenuName; });
          Navigator.pop(context);
        });
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(text), const Icon(Icons.arrow_right)]),
    ));
  }

  List<PopupMenuEntry<BoxDetails>> _getWidgetMenus(_Box box) {
    List<PopupMenuEntry<BoxDetails>> popupMenuEntries = [
      PopupMenuItem<BoxDetails>(child: Row(children: [const Icon(Icons.arrow_left), Text('Box', style: TextStyle(decoration: TextDecoration.underline))])),
      _widgetMenuEntry(BlankBox.sid, 'Blank'),
      _widgetSubMenuEntry(box, 'Environment', [
        _widgetSubMenuEntry(box, 'Depth', [
          _widgetSubMenuEntry(box, 'Below Surface', [
            _widgetMenuEntry(DepthBelowSurfaceBox.sid, 'Depth'),
            _widgetMenuEntry(MinDepthBelowSurfaceBox.sid, 'Min Depth'),
            _widgetMenuEntry(DepthBelowSurfaceGraph.sid, 'Depth'),
          ]),
          _widgetSubMenuEntry(box, 'Below Keel', [
            _widgetMenuEntry(DepthBelowKeelBox.sid, 'Depth'),
            _widgetMenuEntry(MinDepthBelowKeelBox.sid, 'Min DBK'),
            _widgetMenuEntry(DepthBelowKeelGraph.sid, 'Depth'),
          ]),
          _widgetSubMenuEntry(box, 'Below Transducer', [
            _widgetMenuEntry(DepthBelowTransducerBox.sid, 'Depth'),
            _widgetMenuEntry(MinDepthBelowTransducerBox.sid, 'Min DBT'),
            _widgetMenuEntry(DepthBelowTransducerGraph.sid, 'Depth'),
          ]),
        ]),
        _widgetSubMenuEntry(box, 'Temperature', [
          _widgetMenuEntry(WaterTemperatureBox.sid, 'Water'),
          _widgetMenuEntry(WaterTemperatureGraph.sid, 'Water'),
          _widgetMenuEntry(OutsideTemperatureBox.sid, 'Outside'),
          _widgetMenuEntry(OutsideTemperatureGraph.sid, 'Outside'),
        ]),
        _widgetSubMenuEntry(box, 'Pressure', [
          _widgetMenuEntry(OutsidePressureBox.sid, 'Outside'),
          _widgetMenuEntry(OutsidePressureGraph.sid, 'Outside'),
        ]),
        _widgetSubMenuEntry(box, 'Humidity', [
          _widgetMenuEntry(OutsideHumidityBox.sid, 'Outside'),
          _widgetMenuEntry(InsideHumidityBox.sid, 'Inside'),
        ]),
        _widgetMenuEntry(SetAndDriftBox.sid, 'Set & Drift'),
        _widgetMenuEntry(SunlightBox.sid, 'Sunlight'),
        _widgetMenuEntry(MoonBox.sid, 'Moonlight'),
      ]),
      _widgetSubMenuEntry(box, 'Navigation', [
        _widgetMenuEntry(CompassRoseBox.sid, 'Compass Rose'),
        _widgetMenuEntry(CompassGaugeBox.sid, 'Compass Gauge'),
        _widgetSubMenuEntry(box, 'Speed', [
          _widgetMenuEntry(SpeedOverGroundBox.sid, 'Over Ground'),
          _widgetMenuEntry(MaxSpeedOverGroundBox.sid, 'Max SOG'),
          _widgetMenuEntry(SpeedOverGroundGraph.sid, 'Over Ground'),
        ]),
        _widgetMenuEntry(PositionBox.sid, 'Position'),
        _widgetMenuEntry(CourseOverGroundBox.sid, 'Course Over Ground'),
        _widgetMenuEntry(HeadingTrueBox.sid, 'Heading'),
        _widgetMenuEntry(HeadingMagneticBox.sid, 'Magnetic Heading'),
        _widgetSubMenuEntry(box, 'Next Waypoint', [
          _widgetMenuEntry(NextPointDistanceBox.sid, 'Distance'),
          _widgetMenuEntry(NextPointVelocityMadeGoodBox.sid, 'VMG'),
          _widgetMenuEntry(NextPointTimeToGoBox.sid, 'Time'),
          _widgetMenuEntry(NextPointBearingBox.sid, 'Bearing'),
        ]),
        // _widgetMenuEntry(RouteTimeToGoBox.sid),
        _widgetSubMenuEntry(box, 'Cross Track Error', [
          _widgetMenuEntry(CrossTrackErrorBox.sid, 'XTE'),
          _widgetMenuEntry(CrossTrackErrorGraph.sid, 'XTE'),
          _widgetMenuEntry(CrossTrackErrorDeltaBox.sid, 'XTE Delta'),
        ]),
        _widgetMenuEntry(RateOfTurnBox.sid, 'Rate of Turn'),
        _widgetMenuEntry(MagneticVariationBox.sid, 'Magnetic Variation'),
      ]),
      _widgetSubMenuEntry(box, 'Boat', [
        _widgetSubMenuEntry(box, 'Speed', [
          _widgetMenuEntry(SpeedThroughWaterBox.sid, 'STW'),
          _widgetMenuEntry(MaxSpeedThroughWaterBox.sid, 'Max STW'),
          _widgetMenuEntry(SpeedThroughWaterGraph.sid, 'STW'),
        ]),
        _widgetMenuEntry(RudderAngleBox.sid, 'Rudder Angle'),
        _widgetMenuEntry(AttitudeRollGaugeBox.sid, 'Roll'),
      ]),
      _widgetSubMenuEntry(box, 'Wind', [
        _widgetSubMenuEntry(box, 'Apparent Wind', [
          _widgetMenuEntry(WindSpeedApparentBox.sid, 'Speed'),
          _widgetMenuEntry(MaxWindSpeedApparentBox.sid, 'Max Speed'),
          _widgetMenuEntry(ApparentWindSpeedGraph.sid, 'Speed'),
          _widgetMenuEntry(WindAngleApparentBox.sid, 'Angle'),
        ]),
        _widgetSubMenuEntry(box, 'True Wind', [
          _widgetMenuEntry(WindSpeedTrueBox.sid, 'Speed'),
          _widgetMenuEntry(MaxWindSpeedTrueBox.sid, 'Max Speed'),
          _widgetMenuEntry(TrueWindSpeedGraph.sid, 'Speed'),
          _widgetMenuEntry(WindDirectionTrueBox.sid, 'Direction'),
          _widgetMenuEntry(WindSpeedTrueBeaufortBox.sid, 'Beaufort'),
        ]),
        _widgetMenuEntry(WindRoseBox.sid, 'Rose'),
      ]),
      _widgetSubMenuEntry(box, 'Autopilot', [
        _widgetMenuEntry(AutopilotStatusBox.sid, 'State'),
        _widgetSubMenuEntry(box, 'State Control', [
          _widgetMenuEntry(AutopilotStateControlHorizontalBox.sid, 'Horizontal'),
          _widgetMenuEntry(AutopilotStateControlVerticalBox.sid, 'Vertical'),
        ]),
        _widgetSubMenuEntry(box, 'Heading Control', [
          _widgetMenuEntry(AutopilotHeadingControlHorizontalBox.sid, 'Horizontal'),
          _widgetMenuEntry(AutopilotHeadingControlVerticalBox.sid, 'Vertical'),
        ]),
      ]),
      _widgetSubMenuEntry(box, 'Electrical', [
        _widgetSubMenuEntry(box, 'Batteries', [
          _widgetMenuEntry(BatteriesBox.sid, 'All'),
          _widgetMenuEntry(BatteryPowerGraph.sid, 'Power Usage'),
          _widgetMenuEntry(BatteryVoltMeterBox.sid, 'Volt Meter'),
          _widgetMenuEntry(BatteryVoltageBox.sid, 'Voltage'),
          _widgetMenuEntry(BatteryCurrentBox.sid, 'Current'),
          _widgetMenuEntry(BatteryTemperatureBox.sid, 'Temperature'),
        ]),
        _widgetSubMenuEntry(box, 'Solar', [
          _widgetMenuEntry(SolarVoltageBox.sid, 'Voltage'),
          _widgetMenuEntry(SolarCurrentBox.sid, 'Current'),
          _widgetMenuEntry(SolarPowerGraph.sid, 'Power'),
        ]),
        _widgetMenuEntry(InverterCurrentBox.sid, 'Inverter Current'),
        _widgetMenuEntry(ElectricalSwitchesBox.sid, 'Switches'),
        _widgetMenuEntry(ElectricalSwitchBox.sid, 'Switch'),
      ]),
      _widgetSubMenuEntry(box, 'Tanks', [
        _widgetMenuEntry(TanksBox.sid, 'Tanks'),
        _widgetMenuEntry(FreshWaterTankBox.sid, 'Fresh'),
        _widgetMenuEntry(GreyWaterTankBox.sid, 'Grey'),
        _widgetMenuEntry(BlackWaterTankBox.sid, 'Black'),
        _widgetMenuEntry(FuelTankBox.sid, 'Fuel'),
        _widgetMenuEntry(LubricationTankBox.sid, 'Lubrication'),
      ]),
      _widgetSubMenuEntry(box, 'Engine', [
        _widgetMenuEntry(EngineRPMBox.sid, 'RPM'),
        _widgetMenuEntry(EngineTempBox.sid, 'Temperature'),
        _widgetMenuEntry(EngineOilPressureBox.sid, 'Oil Pressure'),
        _widgetMenuEntry(EngineExhaustTempBox.sid, 'Exhaust Temp'),
        _widgetMenuEntry(EngineFuelRateBox.sid, 'Fuel Rate'),
      ]),
      _widgetSubMenuEntry(box, 'Raspberry Pi', [
        _widgetMenuEntry(RPiCPUTemperatureBox.sid, 'CPU Temp'),
        _widgetMenuEntry(RPiGPUTemperatureBox.sid, 'GPU Temp'),
        _widgetMenuEntry(RPiCPUUtilisationBox.sid, 'CPU Utilisation'),
        _widgetMenuEntry(RPiMemoryUtilisationBox.sid, 'Memory Utilisation'),
        _widgetMenuEntry(RPiSDUtilisationBox.sid, 'Disk Utilisation'),
        _widgetMenuEntry(RaspberryPiBox.sid, 'Raspberry Pi'),
      ]),
      _widgetMenuEntry(DateTimeBox.sid, 'Date/Time'),
      _widgetMenuEntry(AnchorAlarmBox.sid, 'Anchor Alarm'),
      _widgetMenuEntry(WebViewBox.sid, 'Web View'),
      _widgetMenuEntry(VNCBox.sid, 'VNC'),
      _widgetSubMenuEntry(box, 'Custom', [
        _widgetMenuEntry(CustomTextBox.sid, 'Text'),
        _widgetMenuEntry(CustomDoubleValueBox.sid, 'Value'),
        _widgetMenuEntry(CustomDoubleValueSemiGaugeBox.sid, 'Semi Gauge'),
        _widgetMenuEntry(CustomDoubleValueCircularGaugeBox.sid, 'Circular Gauge'),
        _widgetMenuEntry(CustomDoubleValueBarGaugeBox.sid, 'Bar Gauge'),
        _widgetMenuEntry(DebugBox.sid, 'Debug'),
      ]),
    ];

    return popupMenuEntries;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageRows = [];
    List<double> pageRowsPercent = [];

    for(int pri = 0; pri < widget._editPage.pageRows.length; ++pri) {
      _PageRow pageRow = widget._editPage.pageRows[pri];

      List<Widget> columns = [];
      List<double> columnsPercent = [];

      for(int ci = 0; ci < pageRow.columns.length; ++ci) {
        _Column column = pageRow.columns[ci];

        List<Widget> rows = [];
        List<double> rowsPercent = [];

        for (int ri = 0; ri < column.rows.length; ++ri) {
          _Row row = column.rows[ri];

          List<Widget> boxes = [];
          List<double> boxesPercent = [];

          for (int bi = 0; bi < row.boxes.length; ++bi) {
            _Box box = row.boxes[bi];

            List<Widget> nButtons = [];
            List<Widget> sButtons = [];
            List<Widget> eButtons = [];
            List<Widget> wButtons = [];

            wButtons.add(IconButton(tooltip: 'Box Before', onPressed: () {_addBox(row, bi);}, icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.blue)));

            if(bi == 0 && ri == 0 && ci == 0) {
              nButtons.add(IconButton(tooltip: 'Page Row Above', onPressed: () {_addPageRow(widget._editPage, pri);}, icon: const Icon(Icons.arrow_circle_up_outlined, color: Colors.red)));
            }

            if(bi == 0 && ri == 0) {
              wButtons.add(IconButton(tooltip: 'Column Before', onPressed: () {_addColumn(pageRow, ci);}, icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.orange)));
            }

            if(bi == 0) {
              nButtons.add(IconButton(tooltip: 'Row Above', onPressed: () {_addRow(column, ri);}, icon: const Icon(Icons.arrow_circle_up_outlined, color: Colors.yellow)));
            }

            if(bi == row.boxes.length-1) {
              eButtons.add(IconButton(tooltip: 'Box After', onPressed: () {_addBox(row, bi, after: true);}, icon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.blue)));
            }

            if(pri == (widget._editPage.pageRows.length-1) && ci == 0 && ri == (column.rows.length-1) && bi == 0) {
              sButtons.add(IconButton(tooltip: 'Page Row Below', onPressed: () {_addPageRow(widget._editPage, pri, after: true);}, icon: const Icon(Icons.arrow_circle_down_outlined, color: Colors.red)));
            }

            if(ci == pageRow.columns.length-1 && ri == 0 && bi == row.boxes.length-1) {
              eButtons.add(IconButton(tooltip: 'Column After', onPressed: () {_addColumn(pageRow, ci, after: true);}, icon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.orange)));
            }

            if(ri == column.rows.length-1 && bi == 0) {
              sButtons.add(IconButton(tooltip: 'Row Below', onPressed: () {_addRow(column, ri, after: true);}, icon: const Icon(Icons.arrow_circle_down_outlined, color: Colors.yellow)));
            }

            LayoutBuilder layoutBoxWidget = LayoutBuilder(builder: (context, constraints) {
              return getBoxDetails(box.id).build(BoxWidgetConfig(widget._controller, box.settings, constraints, true));
            });

            PopupMenuButton boxWidgetMenu = PopupMenuButton(
              routeSettings: RouteSettings(name: _boxMenuName),
              icon: const Icon(Icons.list, color: Colors.blue),
              tooltip: 'Box Type',
              shape: Border.all(color: Colors.grey),
              itemBuilder: (BuildContext context) {
                return _getWidgetMenus(box);
              },
              onSelected: (value) {
                setState(() {
                  box.id = (value as BoxDetails).id;
                });
              },
            );

            List<Widget> stack = [
              layoutBoxWidget
            ];

            BoxWidget editBoxWidget = getBoxDetails(box.id).build(BoxWidgetConfig(widget._controller, box.settings, const BoxConstraints(maxWidth: 1.0, maxHeight: 1.0), true));

            List<Widget> settingsButtons = [];
            Widget? helpWidget = editBoxWidget.getHelp(context);
            if(helpWidget != null) {
              settingsButtons.add(IconButton(onPressed: () {_showHelpPage(helpWidget);}, icon: const Icon(Icons.help)));
            }

            if(editBoxWidget.hasSettings) {
              settingsButtons.add(IconButton(tooltip: 'Settings', onPressed: () {_showSettingsPage(editBoxWidget);}, icon: const Icon(Icons.settings)));
            }
            if(editBoxWidget.hasPerBoxSettings) {
              settingsButtons.add(IconButton(tooltip: 'Box Settings', onPressed: () {_showPerBoxSettingsPage(editBoxWidget, pri, ci, ri, bi);}, icon: const Icon(Icons.settings, color: Colors.blue)));
            }

            stack.addAll([
              Positioned(top: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: nButtons)),
              Positioned(bottom: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: sButtons)),
              Positioned(right: 0, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: eButtons)),
              Positioned(left: 0, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: wButtons)),
              Positioned(top: 0, right: 0, child: Row(children: settingsButtons)),
              Positioned(bottom: 0, left: 0, child: IconButton(tooltip: 'Delete Box', onPressed: () {_deleteBox(pri, ci, ri, bi);}, icon: const Icon(Icons.delete, color: Colors.blue))),
              boxWidgetMenu
            ]);
            boxes.add(Stack(alignment: Alignment.center, children: stack));

            boxesPercent.add(box.percentage);
          }

          rows.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, row.boxes);}, isHorizontalSeparator: false, separatorColor: Colors.blue, separatorSize: 16, percentages: boxesPercent, children: boxes));
          rowsPercent.add(row.percentage);
        }

        columns.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, column.rows);}, isHorizontalSeparator: true, separatorColor: Colors.yellow, separatorSize: 16, percentages: rowsPercent, children: rows));
        columnsPercent.add(column.percentage);
      }

      pageRows.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, pageRow.columns);}, isHorizontalSeparator: false, separatorColor: Colors.orange, separatorSize: 16, percentages: columnsPercent, children: columns));
      pageRowsPercent.add(pageRow.percentage);
    }

    return Scaffold(
      body: SafeArea(child: ResizableWidget(key: UniqueKey(), onResized: (infoList) {_onResize(infoList, widget._editPage.pageRows);}, isHorizontalSeparator: true, separatorColor: Colors.red, separatorSize: 16, percentages: pageRowsPercent, children: pageRows)),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(icon: const Icon(Icons.save), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)), onPressed: _save),
        IconButton(icon: const Icon(Icons.close), style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)), onPressed: _discard)
      ])
    );
  }

  void _onResize(List<WidgetSizeInfo> infoList, List<_Resizable> r) {
    assert(infoList.length == r.length);

    // To deal with rounding errors, we always make the last percentage what's remaining.
    double total = 0;
    int i;
    for(i = 0; i < infoList.length-1; ++i) {
      r[i].percentage = infoList[i].percentage;
      total += infoList[i].percentage;
    }
    r[i].percentage = 1.0 - total;
  }

  // We need this to adjust for rounding errors.
  static double _diff(List<_Resizable> list) {
    double tot = 0;
    for(_Resizable r in list) {
      tot += r.percentage;
    }
    return 1.0 - tot;
  }

  void _addBox(_Row r, int bi, {bool after = false}) {
    setState(() {
      _Box b = _Box.blank();
      double pc = r.boxes[bi].percentage / 2;
      r.boxes[bi].percentage = pc;
      b.percentage = pc;
      r.boxes.insert(after ? bi+1 : bi, b);
      b.percentage += _diff(r.boxes);
    });
  }

  void _addRow(_Column c, int ri, {bool after = false}) {
    setState(() {
      _Row r = _Row([_Box.blank()], 1);
      double pc = c.rows[ri].percentage / 2;
      c.rows[ri].percentage = pc;
      r.percentage = pc;
      c.rows.insert(after ? ri+1 : ri, r);
      r.percentage += _diff(c.rows);
    });
  }

  void _addColumn(_PageRow pr, int ci, {bool after = false}) {
    setState(() {
      _Column c = _Column([_Row([_Box.blank()], 1)], 1);
      double pc = pr.columns[ci].percentage / 2;
      pr.columns[ci].percentage = pc;
      c.percentage = pc;
      pr.columns.insert(after ? ci+1 : ci, c);
      c.percentage += _diff(pr.columns);
    });
  }

  void _addPageRow(_Page p, int pri, {bool after = false}) {
    setState(() {
      _PageRow pr = _PageRow([_Column([_Row([_Box.blank()], 1)], 1)], 1);
      double ppr = p.pageRows[pri].percentage / 2;
      p.pageRows[pri].percentage = ppr;
      pr.percentage = ppr;
      p.pageRows.insert(after ? pri+1 : pri, pr);
      pr.percentage += _diff(p.pageRows);
    });
  }

  void _deleteBox(int pri, int ci, int ri, int bi) {
    _Page page = widget._editPage;

    setState(() {
      _Box b = page.pageRows[pri].columns[ci].rows[ri].boxes[bi];
      page.pageRows[pri].columns[ci].rows[ri].boxes.removeAt(bi);
      if(page.pageRows[pri].columns[ci].rows[ri].boxes.isNotEmpty) {
        if(bi >= page.pageRows[pri].columns[ci].rows[ri].boxes.length) {
          --bi;
        }
        page.pageRows[pri].columns[ci].rows[ri].boxes[bi].percentage += b.percentage;
      } else {
        _Row r = page.pageRows[pri].columns[ci].rows[ri];
        page.pageRows[pri].columns[ci].rows.removeAt(ri);
        if(page.pageRows[pri].columns[ci].rows.isNotEmpty) {
          if(ri >= page.pageRows[pri].columns[ci].rows.length) {
            --ri;
          }
          page.pageRows[pri].columns[ci].rows[ri].percentage += r.percentage;
        } else {
          _Column c = page.pageRows[pri].columns[ci];
          page.pageRows[pri].columns.removeAt(ci);
          if(page.pageRows[pri].columns.isNotEmpty) {
            if(ci >= page.pageRows[pri].columns.length) {
              --ci;
            }
            page.pageRows[pri].columns[ci].percentage += c.percentage;
          } else {
            _PageRow pr = page.pageRows[pri];
            page.pageRows.removeAt(pri);
            if(page.pageRows.isNotEmpty) {
              if(pri >= page.pageRows.length) {
                --pri;
              }
              page.pageRows[pri].percentage += pr.percentage;
            } else {
              // Need to have one Box for the current screen.
              page.pageRows = [_PageRow([_Column([_Row([_Box.blank()], 1.0)], 1.0)], 1)];
          }
        }
      }
      }
    });
  }

  void _save() {
    widget._page.pageRows = widget._editPage.pageRows;
    widget._controller.save();
    Navigator.pop(context);
  }

  void _discard() async {
    if(await widget._controller.askToConfirm(context, "Discard Changes?", alwaysAsk: true)) {
      if(mounted) Navigator.pop(context);
    }
  }

  Future<void> _showSettingsPage (BoxWidget boxWidget) async {
    BoxSettingsWidget boxSettingsWidget =  boxWidget.getSettingsWidget(widget._controller.getBoxSettingsJson(boxWidget.id))!;

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _BoxSettingsPage(
              boxSettingsWidget,
              boxWidget.getSettingsHelp()
          );
        })
    );

    widget._controller._settings?.boxSettings[boxWidget.id] = boxSettingsWidget.getSettingsJson();

    setState(() {});
  }

  Future<void> _showPerBoxSettingsPage (BoxWidget boxWidget, int pri, int ci, ri, bi) async {
    BoxSettingsWidget boxSettingsWidget = boxWidget.getPerBoxSettingsWidget()!;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _BoxSettingsPage(boxSettingsWidget, boxWidget.getPerBoxSettingsHelp());
    }));

    widget._editPage.pageRows[pri].columns[ci].rows[ri].boxes[bi].settings = boxSettingsWidget.getSettingsJson();

    setState(() {});
  }

  Future<void> _showHelpPage (Widget helpWidget) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _BoxHelpPage(helpWidget);
    }));
  }

}

class _BoxSettingsPage extends StatefulWidget {
  final Widget _settingsWidget;
  final Widget? _helpWidget;

  const _BoxSettingsPage(this._settingsWidget, this._helpWidget);

  @override
  createState() => _BoxSettingsState();
}

class _BoxSettingsState extends State<_BoxSettingsPage> {

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (widget._helpWidget != null) {
      actions.add(IconButton(tooltip: 'Help', onPressed: _showHelpPage, icon: const Icon(Icons.help)));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: actions,
        ),
        body: widget._settingsWidget
    );
  }

  Future<void> _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _BoxHelpPage(widget._helpWidget!);
    }));
  }
}

class _BoxHelpPage extends StatefulWidget {
  final Widget _helpWidget;

  const _BoxHelpPage(this._helpWidget);

  @override
  createState() => _BoxHelpState();
}

class _BoxHelpState extends State<_BoxHelpPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Help'),
        ),
        body: widget._helpWidget,
    );
  }
}
