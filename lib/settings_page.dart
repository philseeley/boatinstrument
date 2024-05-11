part of 'boatinstrument_controller.dart';

class SettingsPage extends StatefulWidget {
  final BoatInstrumentController _controller;

  const SettingsPage(this._controller, {super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    _Settings settings = widget._controller._settings!;

    List<Widget> list = [
      ListTile(
        leading: const Text("Value Smoothing:"),
        title: Slider(
            min: 1,
            max: 20,
            divisions: 20,
            value: settings.valueSmoothing.toDouble(),
            label: "${settings.valueSmoothing.toInt()}",
            onChanged: (double value) {
              setState(() {
                settings.valueSmoothing = value.toInt();
              });
            }),
      ),
      ListTile(
          leading: const Text("Signalk Server:"),
          title: TextFormField(
              initialValue: settings.signalkServer,
              onChanged: (value) => settings.signalkServer = value)
      ),
      SwitchListTile(title: const Text("Wraparound page change:"),
          value: settings.wrapPages,
          onChanged: (bool value) {
            setState(() {
              settings.wrapPages = value;
            });
          }),
      ListTile(
          leading: const Text("Distance:  "),
          title: _distanceMenu()
      ),
      ListTile(
          leading: const Text("Speed:     "),
          title: _speedMenu()
      ),
      ListTile(
          leading: const Text("Wind Speed:"),
          title: _windSpeedMenu()
      ),
      ListTile(
          leading: const Text("Depth:     "),
          title: _depthMenu()
      ),
      ListTile(
          leading: const Text('Pages:'),
          title: IconButton(icon: const Icon(Icons.add), onPressed: _addPage,)
      ),
    ];

    for(int p = 0; p < settings.pages.length; ++p) {
      _Page page = settings.pages[p];

      list.add(ListTile(
        leading: IconButton(icon: const Icon(Icons.edit), onPressed: () {_editPage(page);}),
        title: TextFormField(
            initialValue: page.name,
            onChanged: (value) => page.name = value),
        trailing: (p == 0) ? null : IconButton(icon: const Icon(Icons.delete), onPressed: () {_deletePage(p);})
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(icon: const Icon(Icons.notes),onPressed:  _showLog)
        ],
      ),
      body: ListView(children: list)
    );
  }

  DropdownMenu _distanceMenu() {
    List<DropdownMenuEntry<DistanceUnits>> l = [];
    for(var v in DistanceUnits.values) {
      l.add(DropdownMenuEntry<DistanceUnits>(
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<DistanceUnits>(
      initialSelection: widget._controller._settings?.distanceUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.distanceUnits = value!;
      },
    );

    return menu;
  }

  DropdownMenu _speedMenu() {
    List<DropdownMenuEntry<SpeedUnits>> l = [];
    for(var v in SpeedUnits.values) {
      l.add(DropdownMenuEntry<SpeedUnits>(
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<SpeedUnits>(
      initialSelection: widget._controller._settings?.speedUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.speedUnits = value!;
      },
    );

    return menu;
  }

  DropdownMenu _windSpeedMenu() {
    List<DropdownMenuEntry<SpeedUnits>> l = [];
    for(var v in SpeedUnits.values) {
      l.add(DropdownMenuEntry<SpeedUnits>(
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<SpeedUnits>(
      initialSelection: widget._controller._settings?.windSpeedUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.windSpeedUnits = value!;
      },
    );

    return menu;
  }

  DropdownMenu _depthMenu() {
    List<DropdownMenuEntry<DepthUnits>> l = [];
    for(var v in DepthUnits.values) {
      l.add(DropdownMenuEntry<DepthUnits>(
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<DepthUnits>(
      initialSelection: widget._controller._settings?.depthUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.depthUnits = value!;
      },
    );

    return menu;
  }

  void _showLog () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return const LogDisplay();
    }));

    setState(() {});
  }

  void _addPage() {
    setState(() {
      widget._controller._settings?.pages.add(_Page._newPage());
    });
  }

  void _editPage (_Page page) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _EditPage(widget._controller, page);
    }));
  }

  void _deletePage(int papeNum) {
    setState(() {
      widget._controller._settings?.pages.removeAt(papeNum);
    });
  }
}
