part of 'boatinstrument_controller.dart';

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
            SizedBox(width: 30, child: TextFormField(
                decoration: const InputDecoration(label: Icon(Icons.timer_outlined)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: (page.timeout??'').toString(),
                onChanged: (value) => page.timeout = int.tryParse(value))),
            IconButton(icon: const Icon(Icons.copy), onPressed: () {_copyPage(p, page);}),
            IconButton(icon: const Icon(Icons.delete), onPressed: () {_deletePage(p);}),
            ReorderableDragStartListener(index: p, child: const Icon(Icons.drag_handle))
          ])
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Pages"),
          actions: [
            IconButton(icon: const Icon(Icons.add),onPressed:  _addPage),
            IconButton(icon: const Icon(Icons.settings), onPressed: _showSettingsPage),
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

  void _showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return SettingsPage(widget._controller);
    }));

    widget._controller.save();
  }

  void _editPage (_Page page) async {
    await Navigator.push(
            context, MaterialPageRoute(builder: (context) {
        return _EditPage(widget._controller, page);
      }));
  }

  _copyPage(int pageNum, _Page page) {
    setState(() {
      widget._controller._settings?.pages.insert(pageNum+1, page.clone());
      if (widget._controller._settings!.pages.isEmpty) {
        widget._controller._settings?.pages.add(_Page._newPage());
      }
    });
  }

  _deletePage(int pageNum) async {
    if(await widget._controller.askToConfirm(context, 'Delete page "${widget._controller._settings?.pages[pageNum].name}"', alwaysAsk: true)) {
      setState(() {
        widget._controller._settings?.pages.removeAt(pageNum);
        if (widget._controller._settings!.pages.isEmpty) {
          widget._controller._settings?.pages.add(_Page._newPage());
        }
      });
    }
  }
}

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
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      SwitchListTile(title: const Text("Dark Mode:"),
          value: settings.darkMode,
          onChanged: (bool value) {
            setState(() {
              settings.darkMode = value;
              themeProvider.setDarkMode(value);
            });
          }),
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
      SwitchListTile(title: const Text("Show Brightness Controls:"),
          value: settings.brightnessControl,
          onChanged: widget._controller._noBrightnessControls ? null : (bool value) {
            setState(() {
              settings.brightnessControl = value;
              if(!value) {
                ScreenBrightness().resetScreenBrightness();
              }
            });
          }),
      SwitchListTile(title: const Text("Auto confirm actions:"),
          value: settings.autoConfirmActions,
          onChanged: (bool value) {
            setState(() {
              settings.autoConfirmActions = value;
            });
          }),
      SwitchListTile(title: const Text("Rotate Pages on Start:"),
          value: settings.pageTimerOnStart,
          onChanged: (bool value) {
            setState(() {
              settings.pageTimerOnStart = value;
            });
          }),
      ListTile(
          leading: const Text("Distance:   "),
          title: _distanceMenu()
      ),
      ListTile(
        leading: const Text("Meters to NM threshold:"),
        title: Slider(
            min: 100,
            max: 1000,
            divisions: 900,
            value: settings.m2nmThreshold.toDouble(),
            label: "${settings.m2nmThreshold.toInt()}",
            onChanged: settings.distanceUnits != DistanceUnits.nmM ? null : (double value) {
              setState(() {
                settings.m2nmThreshold = value.toInt();
              });
            }),
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
      ListTile(
          leading: const Text("Air Pressure:"),
          title: _airPressureMenu()
      ),
      ListTile(
          leading: const Text("Oil Pressure:"),
          title: _oilPressureMenu()
      ),
      ListTile(
          leading: const Text("Capacities:"),
          title: _capacityMenu()
      ),
      ListTile(
          leading: const Text("Port/Starboard Colours:"),
          title: _portStarboardColorsMenu()
      ),
      const ListTile(
          title: Text("Signalk:"),
      ),
      SwitchListTile(title: const Text("Auto Discover:"),
          value: settings.discoverServer,
          onChanged: settings.demoMode ? null : (bool value) {
            setState(() {
              settings.discoverServer = value;
            });
          }),
      ListTile(
          leading: const Text("Host:"),
          title: TextFormField(enabled: (!settings.discoverServer && !settings.demoMode),
              decoration: const InputDecoration(hintText: 'mypi.local'),
              initialValue: settings.signalkHost,
              onChanged: (value) => settings.signalkHost = value)
      ),
      ListTile(
          leading: const Text("Port:"),
          title: TextFormField(enabled: (!settings.discoverServer && !settings.demoMode),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: settings.signalkPort.toString(),
              onChanged: (value) => settings.signalkPort = int.parse(value)),
      ),
      SwitchListTile(title: const Text("Demo Mode:"),
          value: settings.demoMode,
          onChanged: (bool value) {
            setState(() {
              settings.demoMode = value;
            });
          }),
      ListTile(
          leading: const Text("Subscription Min Period:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: settings.signalkMinPeriod.toString(),
              onChanged: (value) => settings.signalkMinPeriod = int.parse(value)),
          trailing: const Text('ms')
      ),
      ListTile(
          leading: const Text("Connection Timeout:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: settings.signalkConnectionTimeout.toString(),
              onChanged: (value) => settings.signalkConnectionTimeout = int.parse(value)),
          trailing: const Text('ms')
      ),
      ListTile(
          leading: const Text("Data Timeout:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: settings.dataTimeout.toString(),
              onChanged: (value) => settings.dataTimeout = int.parse(value)),
          trailing: const Text('ms')
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _share),
          IconButton(icon: const Icon(Icons.file_open), onPressed: _import),
          IconButton(icon: const Icon(Icons.help), onPressed: _showHelpPage),
          IconButton(icon: const Icon(Icons.notes),onPressed: _showLog)
        ],
      ),
      body: ListView(children: list)
    );
  }

  DropdownMenu _distanceMenu() {
    List<DropdownMenuEntry<DistanceUnits>> l = [];
    for(var v in DistanceUnits.values) {
      l.add(DropdownMenuEntry<DistanceUnits>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<DistanceUnits>(
      initialSelection: widget._controller._settings?.distanceUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        setState(() {
          widget._controller._settings?.distanceUnits = value!;
        });
      },
    );

    return menu;
  }

  DropdownMenu _speedMenu() {
    List<DropdownMenuEntry<SpeedUnits>> l = [];
    for(var v in SpeedUnits.values) {
      l.add(DropdownMenuEntry<SpeedUnits>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
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
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
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
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
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
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
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

  DropdownMenu _airPressureMenu() {
    List<DropdownMenuEntry<AirPressureUnits>> l = [];
    for(var v in AirPressureUnits.values) {
      l.add(DropdownMenuEntry<AirPressureUnits>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<AirPressureUnits>(
      initialSelection: widget._controller._settings?.airPressureUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.airPressureUnits = value!;
      },
    );

    return menu;
  }

  DropdownMenu _oilPressureMenu() {
    List<DropdownMenuEntry<OilPressureUnits>> l = [];
    for(var v in OilPressureUnits.values) {
      l.add(DropdownMenuEntry<OilPressureUnits>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<OilPressureUnits>(
      initialSelection: widget._controller._settings?.oilPressureUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.oilPressureUnits = value!;
      },
    );

    return menu;
  }

  DropdownMenu _capacityMenu() {
    List<DropdownMenuEntry<CapacityUnits>> l = [];
    for(var v in CapacityUnits.values) {
      l.add(DropdownMenuEntry<CapacityUnits>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<CapacityUnits>(
      initialSelection: widget._controller._settings?.capacityUnits,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.capacityUnits = value!;
      },
    );

    return menu;
  }

  DropdownMenu _portStarboardColorsMenu() {
    List<DropdownMenuEntry<PortStarboardColors>> l = [];
    for(var v in PortStarboardColors.values) {
      l.add(DropdownMenuEntry<PortStarboardColors>(
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
          value: v,
          label: v.displayName));
    }

    DropdownMenu menu = DropdownMenu<PortStarboardColors>(
      initialSelection: widget._controller._settings?.portStarboardColors,
      dropdownMenuEntries: l,
      onSelected: (value) {
        widget._controller._settings?.portStarboardColors = value!;
      },
    );

    return menu;
  }

  _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _HelpPage();
    })
    );
  }

  void _showLog () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return const LogDisplay();
    }));
  }

  void _share () async {
    await Share.shareXFiles([XFile(widget._controller._settings!.fileName)], subject: 'Boat Instrument Settings');
  }

  void _import () async {
    FilePickerResult? fpResult = await FilePicker.platform.pickFiles();

    if(fpResult != null) {
      try {
        File f = File(fpResult.files.single.path!);
        widget._controller._settings = await _Settings.readSettings(f);
        setState(() {});
      } catch (e) {
        widget._controller.l.e('Failed to import settings', error: e);
      }
    }
  }
}
