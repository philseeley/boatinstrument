part of 'boatinstrument_controller.dart';

class _EditPage extends StatefulWidget {
  final BoatInstrumentController _controller;
  final _Page _page;
  final _Page _editPage =  _Page('_TMP_', []);

  _EditPage(this._controller, this._page) {

    for(_Column c in _page.columns) {
      _Column ec = _Column([], c.percentage);
      _editPage.columns.add(ec);
      for(_Row r in c.rows) {
        _Row er = _Row([], r.percentage);
        ec.rows.add(er);
        for(_Box b in r.boxes) {
          er.boxes.add(_Box(b.id, b.settings, b.percentage));
        }
      }
    }
  }

  @override
  State<_EditPage> createState() => _EditPageState();
}

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
        _widgetMenuEntry(SeaTemperatureBox.sid)]),
      _widgetSubMenuEntry(box, 'Navigation', [
        _widgetMenuEntry(CourseOverGroundBox.sid),
        _widgetMenuEntry(SpeedOverGroundBox.sid),
        _widgetMenuEntry(PositionBox.sid)]),
      _widgetSubMenuEntry(box, 'Boat', [
        _widgetMenuEntry(SpeedBox.sid)]),
      _widgetSubMenuEntry(box, 'Wind', [
        _widgetMenuEntry(WindSpeedApparentBox.sid),
        _widgetMenuEntry(WindSpeedTrueBox.sid),
        _widgetMenuEntry(WindRoseBox.sid),
        _widgetMenuEntry(WindRoseCHBox.sid)]),
      _widgetSubMenuEntry(box, 'Autopilot', [
        _widgetMenuEntry(AutoPilotStatusBox.sid),
        _widgetMenuEntry(AutoPilotControlBox.sid),
        ]),
      _widgetMenuEntry(WebViewBox.sid)
    ];

    return popupMenuEntries;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columns = [];
    List<double> columnsPercent = [];

    for(int ci = 0; ci < widget._editPage.columns.length; ++ci) {
      _Column column = widget._editPage.columns[ci];

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

          wButtons.add(IconButton(onPressed: () {_addBox(row, bi);}, icon: const Icon(Icons.keyboard_arrow_left, color: Colors.blue)));

          if(bi == 0 && ri == 0) {
            wButtons.add(IconButton(onPressed: () {_addColumn(widget._editPage, ci);}, icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.red)));
          }

          if(bi == 0) {
            nButtons.add(IconButton(onPressed: () {_addRow(column, ri);}, icon: const Icon(Icons.keyboard_arrow_up, color: Colors.orange)));
          }

          if(bi == row.boxes.length-1) {
            eButtons.add(IconButton(onPressed: () {_addBox(row, bi, after: true);}, icon: const Icon(Icons.keyboard_arrow_right, color: Colors.blue)));
          }

          if(ci == widget._editPage.columns.length-1 && ri == 0 && bi == row.boxes.length-1) {
            eButtons.add(IconButton(onPressed: () {_addColumn(widget._editPage, ci, after: true);}, icon: const Icon(Icons.keyboard_double_arrow_right, color: Colors.red)));
          }

          if(ri == column.rows.length-1 && bi == 0) {
            sButtons.add(IconButton(onPressed: () {_addRow(column, ri, after: true);}, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange)));
          }

          LayoutBuilder layoutBoxWidget = LayoutBuilder(builder: (context, constraints) {
            return getBoxDetails(box.id).build(widget._controller, box.settings, null);
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
            layoutBoxWidget,
            boxWidgetMenu
          ];

          BoxWidget editBoxWidget = getBoxDetails(box.id).build(widget._controller, box.settings, null);

          List<Widget> settingsButtons = [];
          if(editBoxWidget.hasSettings) {
            settingsButtons.add(IconButton(onPressed: () {_showSettingsPage(editBoxWidget);}, icon: const Icon(Icons.settings)));
          }
          if(editBoxWidget.hasPerBoxSettings) {
            settingsButtons.add(IconButton(onPressed: () {_showPerBoxSettingsPage(editBoxWidget, ci, ri, bi);}, icon: const Icon(Icons.settings, color: Colors.blue)));
          }
          stack.add(Positioned(top: 0, right: 0, child: Row(children: settingsButtons)));

          stack.addAll([
            Positioned(bottom: 0, left: 0, child: IconButton(onPressed: () {_deleteBox(ci, ri, bi);}, icon: const Icon(Icons.delete, color: Colors.blue))),
            Positioned(top: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: nButtons)),
            Positioned(bottom: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: sButtons)),
            Positioned(right: 0, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: eButtons)),
            Positioned(left: 0, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: wButtons)),
          ]);
          boxes.add(Stack(alignment: Alignment.center, children: stack));

          boxesPercent.add(box.percentage);
        }

        rows.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, row.boxes);}, isHorizontalSeparator: false, separatorColor: Colors.blue, separatorSize: 16, percentages: boxesPercent, children: boxes));
        rowsPercent.add(row.percentage);
      }

      columns.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, column.rows);}, isHorizontalSeparator: true, separatorColor: Colors.orange, separatorSize: 16, percentages: rowsPercent, children: rows));
      columnsPercent.add(column.percentage);
    }

    return Scaffold(
      body: ResizableWidget(key: UniqueKey(), onResized: (infoList) {_onResize(infoList, widget._editPage.columns);}, isHorizontalSeparator: false, separatorColor: Colors.red, separatorSize: 16, percentages: columnsPercent, children: columns),
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

  void _addColumn(_Page p, int ci, {bool after = false}) {
    setState(() {
      _Column c = _Column([_Row([_Box.blank()], 1)], 1);
      double pc = p.columns[ci].percentage / 2;
      p.columns[ci].percentage = pc;
      c.percentage = pc;
      p.columns.insert(after ? ci+1 : ci, c);
      c.percentage += _diff(p.columns);
    });
  }

  void _deleteBox(int ci, int ri, int bi) {
    _Page page = widget._editPage;

    setState(() {
      _Box b = page.columns[ci].rows[ri].boxes[bi];
      page.columns[ci].rows[ri].boxes.removeAt(bi);
      if(page.columns[ci].rows[ri].boxes.isNotEmpty) {
        if(bi >= page.columns[ci].rows[ri].boxes.length) {
          --bi;
        }
        page.columns[ci].rows[ri].boxes[bi].percentage += b.percentage;
      } else {
        _Row r = page.columns[ci].rows[ri];
        page.columns[ci].rows.removeAt(ri);
        if(page.columns[ci].rows.isNotEmpty) {
          if(ri >= page.columns[ci].rows.length) {
            --ri;
          }
          page.columns[ci].rows[ri].percentage += r.percentage;
        } else {
          _Column c = page.columns[ci];
          page.columns.removeAt(ci);
          if(page.columns.isNotEmpty) {
            if(ci >= page.columns.length) {
              --ci;
            }
            page.columns[ci].percentage += c.percentage;
          } else {
            // Need to have one Box for the current screen.
            page.columns = [_Column([_Row([_Box.blank()], 1.0)], 1.0)];
          }
        }
      }
    });
  }

  void _save() {
    widget._page.columns = widget._editPage.columns;
    widget._controller.save();
    _close();
  }

  void _close() {
    Navigator.pop(context);
  }

  _showSettingsPage (BoxWidget boxWidget) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _BoxSettingsPage(
              boxWidget.getSettingsWidget(widget._controller.getBoxSettings(boxWidget.id))!
          );
        })
    );

    widget._controller._settings?.boxSettings[boxWidget.id] = boxWidget.getSettingsJson();

    setState(() {});
  }

  _showPerBoxSettingsPage (BoxWidget boxWidget, int ci, ri, bi) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _BoxSettingsPage(boxWidget.getPerBoxSettingsWidget()!);
    }));

    widget._editPage.columns[ci].rows[ri].boxes[bi].settings = boxWidget.getPerBoxSettingsJson();

    setState(() {});
  }
}

class _BoxSettingsPage extends StatefulWidget {
  final Widget _settingsWidget;

  const _BoxSettingsPage(this._settingsWidget);

  @override
  createState() => _BoxSettingsState();
}

class _BoxSettingsState extends State<_BoxSettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: widget._settingsWidget
    );
  }
}
