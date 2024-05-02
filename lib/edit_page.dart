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
    if(widget._controller._settings!.pages.isEmpty) {
      widget._controller._settings!.pages.add(
          _Page(
              'Page Name',
              [
                [_PageWidget('Press to config.\nLong Press to split', 1)]
              ]));
    }

    _page = widget._controller._settings!.pages[widget._page];
  }

  @override
  Widget build(BuildContext context) {
    if(_page == null) {
      return Container();
    }

    List<Widget> rwl = [];

    for(int ri = 0; ri < _page!.rows.length; ++ri) {
      List<_PageWidget> r = _page!.rows[ri];

      List<Widget> wl = [];
      List<double> pl = [];

      for(int wi = 0; wi < r.length; ++wi) {
        _PageWidget w = r[wi];

        wl.add(Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: TextButton(onLongPress: () {_split(ri, wi);},
              onPressed: () {
                print('pressed');
              }, child: Text(w.id),)));
        pl.add(w.percent);
      }
      print(pl);
      rwl.add(ResizableWidget(
        // key: UniqueKey(),
        onResized: _printResizeInfo,
        separatorColor: Colors.white,
        percentages: pl,
        children: wl,
      ));
    }

    return Scaffold(
      body: ResizableWidget(key: UniqueKey(), children: rwl),
      floatingActionButton: IconButton(icon: const Icon(Icons.save), onPressed: _save,),
    );
  }

  void _split(int ri, int wi) {
    setState(() {
      _page?.rows[ri][wi].percent = 0.5;
      _page?.rows[ri].add(_PageWidget('id', 0.5));
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
