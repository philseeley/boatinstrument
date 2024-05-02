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

    List<Widget> rwl = [];

    for(int ri = 0; ri < _page!.rows.length; ++ri) {
      List<_PageWidget> r = _page!.rows[ri];

      List<Widget> wl = [];
      List<double> pl = [];

      for(int wi = 0; wi < r.length; ++wi) {
        _PageWidget w = r[wi];

        wl.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed: () {_split(ri, wi, 'W');}, icon: const Icon(Icons.splitscreen)),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(onPressed: () {_split(ri, wi, 'N');}, icon: const Icon(Icons.splitscreen)),
            DropdownMenu(initialSelection: getWidgetDetails(w.id), onSelected: (wd) {w.id = wd?.id??'id';}, dropdownMenuEntries: dropdownMenuEntries, textStyle: widget._controller.lineTS),
            IconButton(onPressed: () {_split(ri, wi, 'S');}, icon: const Icon(Icons.splitscreen)),
          ]),
          IconButton(onPressed: () {_split(ri, wi, 'E');}, icon: const Icon(Icons.splitscreen)),
        ]));
        pl.add(w.percent);
      }

      rwl.add(ResizableWidget(
        onResized: _printResizeInfo,
        separatorColor: Colors.white,
        percentages: pl,
        children: wl,
      ));
    }

    return Scaffold(
      body: ResizableWidget(key: UniqueKey(), children: rwl),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(icon: const Icon(Icons.save), onPressed: _save),
        IconButton(icon: const Icon(Icons.close), onPressed: _save) //TODO need to revert
      ])
    );
  }

  void _split(int ri, int wi, String edge) {
    setState(() {
      // switch (edge) {
      //   case 'N':
      //     _page?.rows.insert(ri, [_PageWidget(widgetDetails[0].id, 1)]);
      //     double p = 1 / _page!.rows.length;
      //
      //     for(_PageWidget w in _page!.rows[ri]) {
      //       w.percent = p;
      //     }
      //
      //     break;
      //   case 'S':
      //     _page?.rows.add([_PageWidget(widgetDetails[0].id, 1)]);
      //     break;
      //   case 'E':
      //     _page?.rows[ri].add(_PageWidget(widgetDetails[0].id, 1));
      //     break;
      //   case 'W':
      //     _page?.rows[ri].insert(wi, _PageWidget(widgetDetails[0].id, 1));
      //     break;
      // }
      _page?.rows[ri].add(_PageWidget(widgetDetails[0].id, 0.5));

      double p = 1 / _page!.rows[ri].length;

      for(_PageWidget w in _page!.rows[ri]) {
        w.percent = p;
      }
    });
  }

  void _printResizeInfo(List<WidgetSizeInfo> dataList) {
    print(dataList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
  }

  void _save() {
    Navigator.pop(context);
  }
}
