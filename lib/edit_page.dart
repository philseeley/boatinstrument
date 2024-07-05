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
//TODO XTE delta and graph, Attitude(pitch, yaw, roll)
List<BoxDetails> boxDetails = [
  BoxDetails(BlankBox.sid, 'Blank', (config) {return BlankBox(config, key: UniqueKey());}), // This is the default Box.
  BoxDetails(HelpBox.sid, 'Help', (config) {return HelpBox(config, key: UniqueKey());}), // This is the default Box.
  BoxDetails(DepthBox.sid, 'Depth', (config) {return DepthBox(config, key: UniqueKey());}),
  BoxDetails(SpeedThroughWaterBox.sid, 'Speed Through Water', (config) {return SpeedThroughWaterBox(config, key: UniqueKey());}),
  BoxDetails(SpeedOverGroundBox.sid, 'Speed Over Ground', (config) {return SpeedOverGroundBox(config, key: UniqueKey());}),
  BoxDetails(WindSpeedApparentBox.sid, 'Wind Speed Apparent', (config) {return WindSpeedApparentBox(config, key: UniqueKey());}),
  BoxDetails(WindSpeedTrueBox.sid, 'Wind Speed True', (config) {return WindSpeedTrueBox(config, key: UniqueKey());}),
  BoxDetails(WindDirectionTrueBox.sid, 'Wind Direction True', (config) {return WindDirectionTrueBox(config, key: UniqueKey());}),
  BoxDetails(WindRoseBox.sid, 'Wind Rose', (config) {return WindRoseBox(config, key: UniqueKey());}),
  BoxDetails(PositionBox.sid, 'Position', (config) {return PositionBox(config, key: UniqueKey());}),
  BoxDetails(CourseOverGroundBox.sid, 'Course Over Ground', (config) {return CourseOverGroundBox(config, key: UniqueKey());}),
  BoxDetails(WaterTemperatureBox.sid, 'Sea Temperature', (config) {return WaterTemperatureBox(config, key: UniqueKey());}),
  BoxDetails(AutoPilotStatusBox.sid, 'Autopilot Status', (config) {return AutoPilotStatusBox(config, key: UniqueKey());}),
  BoxDetails(AutoPilotControlBox.sid, 'Autopilot Control', (config) {return AutoPilotControlBox(config, key: UniqueKey());}),
  BoxDetails(WebViewBox.sid, 'Web Page', (config) {return WebViewBox(config, key: UniqueKey());}),
  BoxDetails(RudderAngleBox.sid, 'Rudder Angle', (config) {return RudderAngleBox(config, key: UniqueKey());}),
  BoxDetails(CustomDoubleValueBox.sid, 'Custom Value', (config) {return CustomDoubleValueBox.fromSettings(config, key: UniqueKey());}),
  BoxDetails(DateTimeBox.sid, 'Date/Time', (config) {return DateTimeBox(config, key: UniqueKey());}),
  BoxDetails(CrossTrackErrorBox.sid, 'Cross Track Error', (config) {return CrossTrackErrorBox(config, key: UniqueKey());}),
  BoxDetails(WindSpeedTrueBeaufortBox.sid, 'True Beaufort', (config) {return WindSpeedTrueBeaufortBox(config, key: UniqueKey());}),
  BoxDetails(SetAndDriftBox.sid, 'Set & Drift', (config) {return SetAndDriftBox(config, key: UniqueKey());}),
  BoxDetails(HeadingBox.sid, 'Heading', (config) {return HeadingBox(config, key: UniqueKey());}),
  BoxDetails(NextPointDistanceBox.sid, 'Next Point Distance', (config) {return NextPointDistanceBox(config, key: UniqueKey());}),
  BoxDetails(NextPointVelocityMadeGoodBox.sid, 'Next Point VMG', (config) {return NextPointVelocityMadeGoodBox(config, key: UniqueKey());}),
  BoxDetails(NextPointDistanceTimeToGo.sid, 'Next Point TTG', (config) {return NextPointDistanceTimeToGo(config, key: UniqueKey());}),
  BoxDetails(AttitudeRollGaugeBox.sid, 'Roll Gauge', (config) {return AttitudeRollGaugeBox(config, key: UniqueKey());}),
  BoxDetails(TestGauge.sid, 'Test Gauge', (config) {return TestGauge(config, key: UniqueKey());}),
];

class _EditPageState extends State<_EditPage> {

  PopupMenuItem<BoxDetails> _widgetMenuEntry(String id) {
    BoxDetails wd = getBoxDetails(id);
    return PopupMenuItem<BoxDetails>(value: wd, child: Text(wd.description));
  }

  PopupMenuItem<BoxDetails> _widgetSubMenuEntry(_Box box, String text, List<PopupMenuEntry<BoxDetails>> subMenuEntries) {
    return PopupMenuItem(child: PopupMenuButton<BoxDetails>(
      tooltip: '',
      shape: Border.all(color: Colors.grey),
      itemBuilder: (context) {
        return subMenuEntries;
      },
      onSelected: (value) {
        setState(() {
          box.id = value.id;
          box.settings = {};
          Navigator.pop(context);
        });
      },
      child: ListTile(title: Text(text), trailing: const Icon(Icons.arrow_right)),
    ));
  }

  _getWidgetMenus(_Box box) {
    List<PopupMenuEntry<BoxDetails>> popupMenuEntries = [
      _widgetMenuEntry(BlankBox.sid),
      _widgetSubMenuEntry(box, 'Environment', [
        _widgetMenuEntry(DepthBox.sid),
        _widgetMenuEntry(SetAndDriftBox.sid),
        _widgetMenuEntry(WaterTemperatureBox.sid)]),
      _widgetSubMenuEntry(box, 'Navigation', [
        _widgetMenuEntry(CourseOverGroundBox.sid),
        _widgetMenuEntry(SpeedOverGroundBox.sid),
        _widgetMenuEntry(HeadingBox.sid),
        _widgetMenuEntry(NextPointDistanceBox.sid),
        _widgetMenuEntry(NextPointVelocityMadeGoodBox.sid),
        _widgetMenuEntry(NextPointDistanceTimeToGo.sid),
        _widgetMenuEntry(CrossTrackErrorBox.sid),
        _widgetMenuEntry(PositionBox.sid)]),
      _widgetSubMenuEntry(box, 'Boat', [
        _widgetMenuEntry(SpeedThroughWaterBox.sid),
        _widgetMenuEntry(RudderAngleBox.sid),
        _widgetMenuEntry(AttitudeRollGaugeBox.sid)]),
      _widgetSubMenuEntry(box, 'Wind', [
        _widgetMenuEntry(WindSpeedApparentBox.sid),
        _widgetMenuEntry(WindSpeedTrueBox.sid),
        _widgetMenuEntry(WindDirectionTrueBox.sid),
        _widgetMenuEntry(WindSpeedTrueBeaufortBox.sid),
        _widgetMenuEntry(WindRoseBox.sid)]),
      _widgetSubMenuEntry(box, 'Autopilot', [
        _widgetMenuEntry(AutoPilotStatusBox.sid),
        _widgetMenuEntry(AutoPilotControlBox.sid),
        ]),
      _widgetMenuEntry(WebViewBox.sid),
      _widgetMenuEntry(DateTimeBox.sid),
      // _widgetMenuEntry(TestGauge.sid),
      _widgetSubMenuEntry(box, 'Custom', [
        _widgetMenuEntry(CustomDoubleValueBox.sid)]),
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
              nButtons.add(IconButton(tooltip: 'Row Above', onPressed: () {_addRow(column, ri);}, icon: const Icon(Icons.arrow_circle_up_outlined, color: Colors.green)));
            }

            if(bi == row.boxes.length-1) {
              eButtons.add(IconButton(tooltip: 'Box After', onPressed: () {_addBox(row, bi, after: true);}, icon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.blue)));
            }

            if(pri == (widget._editPage.pageRows.length-1) && ci == 0 && ri == (column.rows.length-1) && bi == 0) {
              sButtons.add(IconButton(tooltip: 'Page Row Below', onPressed: () {_addPageRow(widget._editPage, ci, after: true);}, icon: const Icon(Icons.arrow_circle_down_outlined, color: Colors.red)));
            }

            if(ci == pageRow.columns.length-1 && ri == 0 && bi == row.boxes.length-1) {
              eButtons.add(IconButton(tooltip: 'Column After', onPressed: () {_addColumn(pageRow, ci, after: true);}, icon: const Icon(Icons.arrow_circle_right_outlined, color: Colors.orange)));
            }

            if(ri == column.rows.length-1 && bi == 0) {
              sButtons.add(IconButton(tooltip: 'Row Below', onPressed: () {_addRow(column, ri, after: true);}, icon: const Icon(Icons.arrow_circle_down_outlined, color: Colors.green)));
            }

            LayoutBuilder layoutBoxWidget = LayoutBuilder(builder: (context, constraints) {
              return getBoxDetails(box.id).build(BoxWidgetConfig(widget._controller, box.settings, constraints, true));
            });

            PopupMenuButton boxWidgetMenu = PopupMenuButton(
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

        columns.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, column.rows);}, isHorizontalSeparator: true, separatorColor: Colors.green, separatorSize: 16, percentages: rowsPercent, children: rows));
        columnsPercent.add(column.percentage);
      }

      pageRows.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, pageRow.columns);}, isHorizontalSeparator: false, separatorColor: Colors.orange, separatorSize: 16, percentages: columnsPercent, children: columns));
      pageRowsPercent.add(pageRow.percentage);
    }

    return Scaffold(
      body: ResizableWidget(key: UniqueKey(), onResized: (infoList) {_onResize(infoList, widget._editPage.pageRows);}, isHorizontalSeparator: true, separatorColor: Colors.red, separatorSize: 16, percentages: pageRowsPercent, children: pageRows),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(icon: const Icon(Icons.save), onPressed: _save),
        IconButton(icon: const Icon(Icons.close), onPressed: _close)
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
    _close();
  }

  void _close() {
    Navigator.pop(context);
  }

  _showSettingsPage (BoxWidget boxWidget) async {
    BoxSettingsWidget boxSettingsWidget =  boxWidget.getSettingsWidget(widget._controller.getBoxSettings(boxWidget.id))!;

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

  _showPerBoxSettingsPage (BoxWidget boxWidget, int pri, int ci, ri, bi) async {
    BoxSettingsWidget boxSettingsWidget = boxWidget.getPerBoxSettingsWidget()!;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _BoxSettingsPage(boxSettingsWidget, boxWidget.getPerBoxSettingsHelp());
    }));

    widget._editPage.pageRows[pri].columns[ci].rows[ri].boxes[bi].settings = boxSettingsWidget.getSettingsJson();

    setState(() {});
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
      actions.add(IconButton(onPressed: _showHelpPage, icon: const Icon(Icons.help)));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: actions,
        ),
        body: widget._settingsWidget
    );
  }

  _showHelpPage () async {
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
        body: ListView(children: [ListTile(title: widget._helpWidget)])
    );
  }
}
