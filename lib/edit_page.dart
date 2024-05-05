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

          List<Widget> buttons = [];
          List<Widget> nButtons = [];
          List<Widget> sButtons = [];
          List<Widget> eButtons = [];
          List<Widget> wButtons = [];

          wButtons.add(TextButton(onPressed: () {_addBox(row, bi);}, child: Text('<+', style: widget._controller.headTS.apply(color: Colors.blue))));
          if(bi == 0 && ri == 0) {
            wButtons.add(TextButton(onPressed: () {_addColumn(_page!, ci);}, child: Text('<+', style: widget._controller.headTS.apply(color: Colors.red))));
          }

          if(bi == 0) {
            nButtons.add(TextButton(onPressed: () {_addRow(column, ri);}, child: Text('^\n+', style: widget._controller.headTS.apply(color: Colors.orange))));
          }

          if(bi == row.boxes.length-1) {
            eButtons.add(TextButton(onPressed: () {_addBox(row, bi, after: true);}, child: Text('+>', style: widget._controller.headTS.apply(color: Colors.blue))));
          }

          if(ci == _page!.columns.length-1 && ri == 0 && bi == row.boxes.length-1) {
            eButtons.add(TextButton(onPressed: () {_addColumn(_page!, ci, after: true);}, child: Text('+>', style: widget._controller.headTS.apply(color: Colors.red))));
          }

          if(ri == column.rows.length-1 && bi == 0) {
            sButtons.add(TextButton(onPressed: () {_addRow(column, ri, after: true);}, child: Text('+\nv', style: widget._controller.headTS.apply(color: Colors.orange))));
          }

          buttons.add(Column(mainAxisAlignment: MainAxisAlignment.center, children: wButtons));

          buttons.add(Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: nButtons),
            DropdownMenu(initialSelection: getWidgetDetails(box.id), onSelected: (b) {box.id = b?.id??'id';}, dropdownMenuEntries: dropdownMenuEntries, textStyle: widget._controller.lineTS),
            Row(children: sButtons)
          ]));

          buttons.add(Column(mainAxisAlignment: MainAxisAlignment.center, children: eButtons));

          boxes.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: buttons));

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

  void _save() {
    Navigator.pop(context);
  }
}
