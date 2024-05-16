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
      SwitchListTile(title: const Text("Keep Screen Awake:"),
          value: settings.keepAwake,
          onChanged: (bool value) {
            setState(() {
              settings.keepAwake = value;
            });
          }),
      SwitchListTile(title: const Text("Auto confirm actions:"),
          value: settings.autoConfirmActions,
          onChanged: (bool value) {
            setState(() {
              settings.autoConfirmActions = value;
            });
          }),
      ListTile(
          leading: const Text("Distance:   "),
          title: _distanceMenu()
      ),
      ListTile(
          leading: const Text("Speed:      "),
          title: _speedMenu()
      ),
      ListTile(
          leading: const Text("Wind Speed: "),
          title: _windSpeedMenu()
      ),
      ListTile(
          leading: const Text("Depth:      "),
          title: _depthMenu()
      ),
      ListTile(
          leading: const Text("Temperature:"),
          title: _temperatureMenu()
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [//TODO share as file or string.
          IconButton(icon: const Icon(Icons.web), onPressed: _editPages),
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

  DropdownMenu _temperatureMenu() {
    List<DropdownMenuEntry<TemperatureUnits>> l = [];
    for(var v in TemperatureUnits.values) {
      l.add(DropdownMenuEntry<TemperatureUnits>(
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<TemperatureUnits>(
      initialSelection: widget._controller._settings?.temperatureUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.temperatureUnits = value!;
      },
    );

    return menu;
  }

  void _showLog () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return const LogDisplay();
    }));
  }

  void _editPages () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return EditPagesPage(widget._controller);
    }));
  }
}

class EditPagesPage extends StatefulWidget {
  final BoatInstrumentController _controller;

  const EditPagesPage(this._controller, {super.key});

  @override
  createState() => _EditPagesState();
}

class _EditPagesState extends State<EditPagesPage> {

  @override
  Widget build(BuildContext context) {
    _Settings settings = widget._controller._settings!;

    List<Widget> pageList = [];
    for(int p = 0; p < settings.pages.length; ++p) {
      _Page page = settings.pages[p];

      pageList.add(ListTile(key: UniqueKey(),
          leading: IconButton(icon: const Icon(Icons.edit), onPressed: () {_editPage(page);}),
          title: TextFormField(
              initialValue: page.name,
              onChanged: (value) => page.name = value),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.delete), onPressed: () {_deletePage(p);}),
            ReorderableDragStartListener(index: p, child: const Icon(Icons.drag_handle))
          ])
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Pages"),
          actions: [
            IconButton(icon: const Icon(Icons.add),onPressed:  _addPage)
          ],
        ),
        body: ReorderableListView(buildDefaultDragHandles: false, children: pageList, onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            _Page p = settings.pages.removeAt(oldIndex);
            settings.pages.insert(newIndex, p);
          });
        })
    );
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

  _deletePage(int papeNum) async {
    if(await widget._controller.askToConfirm(context, 'Delete page "${widget._controller._settings?.pages[papeNum].name}"', alwaysAsk: true)) {
      setState(() {
        widget._controller._settings?.pages.removeAt(papeNum);
        if (widget._controller._settings!.pages.isEmpty) {
          widget._controller._settings?.pages.add(_Page._newPage());
        }
      });
    }
  }
}