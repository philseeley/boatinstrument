part of 'boatinstrument_controller.dart';

class EditPage extends StatefulWidget {
  final BoatInstrumentController _controller;
  final int _page;

  const EditPage(this._controller, this._page, {super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  _Page? _page;

  @override
  initState() {
    super.initState();
    _page = widget._controller._settings!.pages[widget._page];
  }

  @override
  Widget build(BuildContext context) {
    if(_page == null) {
      return Container();
    }

    List<DropdownMenuEntry<WidgetDetails>> dropdownMenuEntries = [];
    for(WidgetDetails wd in widgetDetails) {
      dropdownMenuEntries.add(DropdownMenuEntry(value: wd, label: wd.description, style: TextButton.styleFrom(textStyle: widget._controller.lineTS)));
    }

    //TODO need delete button.
    List<Widget> columns = [];
    List<double> columnsPercent = [];

    for(int ci = 0; ci < _page!.columns.length; ++ci) {
      _Column column = _page!.columns[ci];

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
            wButtons.add(IconButton(onPressed: () {_addColumn(_page!, ci);}, icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.red)));
          }

          if(bi == 0) {
            nButtons.add(IconButton(onPressed: () {_addRow(column, ri);}, icon: const Icon(Icons.keyboard_arrow_up, color: Colors.orange)));
          }

          if(bi == row.boxes.length-1) {
            eButtons.add(IconButton(onPressed: () {_addBox(row, bi, after: true);}, icon: const Icon(Icons.keyboard_arrow_right, color: Colors.blue)));
          }

          if(ci == _page!.columns.length-1 && ri == 0 && bi == row.boxes.length-1) {
            eButtons.add(IconButton(onPressed: () {_addColumn(_page!, ci, after: true);}, icon: const Icon(Icons.keyboard_double_arrow_right, color: Colors.red)));
          }

          if(ri == column.rows.length-1 && bi == 0) {
            sButtons.add(IconButton(onPressed: () {_addRow(column, ri, after: true);}, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange)));
          }

          boxes.add(Stack(alignment: Alignment.center, children: [
            getWidgetDetails(box.id).build(widget._controller),
            Positioned(bottom: 0, right: 0, child: IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.blue))),
            Positioned(bottom: 0, left: 0, child: IconButton(onPressed: () {_deleteBox(ci, ri, bi);}, icon: const Icon(Icons.delete, color: Colors.blue))),
            Positioned(top: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: nButtons)),
            Positioned(bottom: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: sButtons)),
            Positioned(right: 0, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: eButtons)),
            Positioned(left: 0, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: wButtons)),
          ]));

          boxesPercent.add(box.percentage);
        }

        rows.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, row.boxes);}, isHorizontalSeparator: false, separatorColor: Colors.blue, percentages: boxesPercent, children: boxes));
        rowsPercent.add(row.percentage);
      }

      columns.add(ResizableWidget(onResized: (infoList) {_onResize(infoList, column.rows);}, isHorizontalSeparator: true, separatorColor: Colors.orange, percentages: rowsPercent, children: rows));
      columnsPercent.add(column.percentage);
    }

    return Scaffold(
      body: ResizableWidget(key: UniqueKey(), onResized: (infoList) {_onResize(infoList, _page!.columns);}, isHorizontalSeparator: false, separatorColor: Colors.red, percentages: columnsPercent, children: columns),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(icon: const Icon(Icons.save), onPressed: _save),
        IconButton(icon: const Icon(Icons.close), onPressed: _save) //TODO need to revert
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

  void _addBox(_Row r, int bi, {bool after = false}) {
    setState(() {
      _Box b = _Box(widgetDetails[0].id, 1);
      double pc = r.boxes[bi].percentage / 2;
      r.boxes[bi].percentage = pc;
      b.percentage = pc;
      r.boxes.insert(after ? bi+1 : bi, b);
    });
  }

  void _addRow(_Column c, int ri, {bool after = false}) {
    setState(() {
      _Row r = _Row([_Box(widgetDetails[0].id, 1)], 1);
      double pc = c.rows[ri].percentage / 2;
      c.rows[ri].percentage = pc;
      r.percentage = pc;
      c.rows.insert(after ? ri+1 : ri, r);
    });
  }

  void _addColumn(_Page p, int ci, {bool after = false}) {
    setState(() {
      _Column c = _Column([_Row([_Box(widgetDetails[0].id, 1)], 1)], 1);
      double pc = p.columns[ci].percentage / 2;
      p.columns[ci].percentage = pc;
      c.percentage = pc;
      p.columns.insert(after ? ci+1 : ci, c);
    });
  }

  void _deleteBox(int ci, int ri, int bi) {
    bool deletePage = false;

    setState(() {
      _Box b = _page!.columns[ci].rows[ri].boxes[bi];
      _page!.columns[ci].rows[ri].boxes.removeAt(bi);
      if(_page!.columns[ci].rows[ri].boxes.isNotEmpty) {
        if(bi >= _page!.columns[ci].rows[ri].boxes.length) {
          --bi;
        }
        _page!.columns[ci].rows[ri].boxes[bi].percentage += b.percentage;
      } else {
        _Row r = _page!.columns[ci].rows[ri];
        _page!.columns[ci].rows.removeAt(ri);
        if(_page!.columns[ci].rows.isNotEmpty) {
          if(ri >= _page!.columns[ci].rows.length) {
            --ri;
          }
          _page!.columns[ci].rows[ri].percentage += r.percentage;
        } else {
          _Column c = _page!.columns[ci];
          _page!.columns.removeAt(ci);
          if(_page!.columns.isNotEmpty) {
            if(ci >= _page!.columns.length) {
              --ci;
            }
            _page!.columns[ci].percentage += c.percentage;
          } else {
            // Need to have one Box for the current screen, but this will be deleted.
            _page!.columns = [_Column([_Row([_Box(widgetDetails[0].id, 1.0)], 1)], 1)];
            deletePage = true;
          }
        }
      }
    });

    if(deletePage) {
      //TODO add confirmation dialog.
      widget._controller._settings!.pages.removeAt(widget._page);
      Navigator.pop(context, true); // Return true if we deleted the page.
    }
  }

  void _save() {
    Navigator.pop(context, false); // Return false if the page was not deleted.
  }
}
