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
            IconButton(icon: const Icon(Icons.content_copy), onPressed: () {_copyPage(p, page);}),
            IconButton(icon: const Icon(Icons.delete), onPressed: () {_deletePage(p);}),
            ReorderableDragStartListener(index: p, child: const Icon(Icons.drag_handle))
          ])
      ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Pages"),
          actions: [
            IconButton(tooltip: 'Add Page', icon: const Icon(Icons.add),onPressed:  _addPage),
            IconButton(tooltip: 'Settings', icon: const Icon(Icons.settings), onPressed: _showSettingsPage),
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

  void _copyPage(int pageNum, _Page page) {
    setState(() {
      widget._controller._settings?.pages.insert(pageNum+1, page.clone());
      if (widget._controller._settings!.pages.isEmpty) {
        widget._controller._settings?.pages.add(_Page._newPage());
      }
    });
  }

  Future<void> _deletePage(int pageNum) async {
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

class _Divider extends StatelessWidget {
  final String _title;

  const _Divider(this._title);

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.secondary;
    return Row(children: [
      Expanded(child: Divider(thickness: 3, color: color)),
      Text(' $_title '),
      Expanded(child: Divider(thickness: 3, color: color))
    ]);
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
            min: 0,
            max: 20,
            divisions: 21,
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
                ScreenBrightness().resetApplicationScreenBrightness();
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
      _Divider('Units'), //=====================================================
      ListTile(
          leading: const Text("Distance:   "),
          title: EnumDropdownMenu(
            DistanceUnits.values,
            widget._controller._settings?.distanceUnits,
            (v) {
              setState(() {
                widget._controller._settings?.distanceUnits = v!;
              });
            })
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
          leading: const Text("Speed:       "),
          title: EnumDropdownMenu(SpeedUnits.values, widget._controller._settings?.speedUnits, (v) {widget._controller._settings?.speedUnits = v!;})
      ),
      ListTile(
          leading: const Text("Wind Speed:  "),
          title: EnumDropdownMenu(SpeedUnits.values, widget._controller._settings?.windSpeedUnits, (v) {widget._controller._settings?.windSpeedUnits = v!;})
      ),
      ListTile(
          leading: const Text("Depth:       "),
          title: EnumDropdownMenu(DepthUnits.values, widget._controller._settings?.depthUnits, (v) {widget._controller._settings?.depthUnits = v!;})
      ),
      ListTile(
          leading: const Text("Temperature: "),
          title: EnumDropdownMenu(TemperatureUnits.values, widget._controller._settings?.temperatureUnits, (v) {widget._controller._settings?.temperatureUnits = v!;})
      ),
      ListTile(
          leading: const Text("Air Pressure:"),
          title: EnumDropdownMenu(AirPressureUnits.values, widget._controller._settings?.airPressureUnits, (v) {widget._controller._settings?.airPressureUnits = v!;})
      ),
      ListTile(
          leading: const Text("Oil Pressure:"),
          title: EnumDropdownMenu(OilPressureUnits.values, widget._controller._settings?.oilPressureUnits, (v) {widget._controller._settings?.oilPressureUnits = v!;})
      ),
      ListTile(
          leading: const Text("Capacities:  "),
          title: EnumDropdownMenu(CapacityUnits.values, widget._controller._settings?.capacityUnits, (v) {widget._controller._settings?.capacityUnits = v!;})
      ),
      ListTile(
          leading: const Text("Fluid Rate:  "),
          title: EnumDropdownMenu(FluidRateUnits.values, widget._controller._settings?.fluidRateUnits, (v) {widget._controller._settings?.fluidRateUnits = v!;})
      ),
      ListTile(
          leading: const Text("Port/Starboard Colours:"),
          title: EnumDropdownMenu(PortStarboardColors.values, widget._controller._settings?.portStarboardColors, (v) {widget._controller._settings?.portStarboardColors = v!;})
      ),
      _Divider('Signalk'), //=====================================================
      SwitchListTile(title: const Text("Auto Discover:"),
          value: settings.discoverServer,
          onChanged: settings.demoMode ? null : (bool value) {
            setState(() {
              settings.discoverServer = value;
            });
          }),
      ListTile(
          leading: const Text("URL:"),
          title: TextFormField(enabled: (!settings.discoverServer && !settings.demoMode),
              decoration: const InputDecoration(hintText: 'http://mypi.local:3000'),
              initialValue: settings.signalkUrl,
              onChanged: (value) => settings.signalkUrl = value),
          trailing: OutlinedButton(onPressed: _editHttpHeaders, child: Text('Headers')),
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
          leading: const Text("Real-time Data Timeout:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: settings.realTimeDataTimeout.toString(),
              onChanged: (value) => settings.realTimeDataTimeout = int.parse(value)),
          trailing: const Text('ms')
      ),
      ListTile(
          leading: const Text("Infrequent Data Timeout:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: settings.infrequentDataTimeout.toString(),
              onChanged: (value) => settings.infrequentDataTimeout = int.parse(value)),
          trailing: const Text('ms')
      ),
      _Divider('Advanced'), //=====================================================
      ListTile(
        leading: const Text("Notification Mute Timeout:"),
        title: Slider(
            min: 5,
            max: 60,
            divisions: 11,
            value: settings.notificationMuteTimeout.toDouble(),
            label: "${settings.notificationMuteTimeout.toInt()}",
            onChanged: (double value) {
              setState(() {
                settings.notificationMuteTimeout = value.toInt();
              });
            }),
        trailing: const Text('minutes')
      ),
      SwitchListTile(title: const Text("Enable Experimental Boxes:"),
          value: settings.enableExperimentalBoxes,
          onChanged: (bool value) {
            setState(() {
              settings.enableExperimentalBoxes = value;
            });
          }),
      if(widget._controller._enableSetTime) SwitchListTile(title: const Text("Set Time:"),
          value: settings.setTime,
          onChanged: (bool value) {
            setState(() {
              settings.setTime = value;
            });
          }),
    ];

    return Scaffold(
      appBar: ActionsMenuAppBar(
        actionsPercent: 0.5,
        context: context,
        title: const Text("Settings"),
        actions: [
          if(widget._controller._enableExit) IconButton(tooltip: 'Exit', icon: const Icon(Icons.power_settings_new), onPressed: _exit),
          IconButton(tooltip: 'Export', icon: const Icon(Icons.share), onPressed: _share),
          IconButton(tooltip: 'Import', icon: const Icon(Icons.file_open), onPressed: _import),
          IconButton(tooltip: 'Subscriptions', icon: const Icon(Icons.mediation),onPressed: _showPathSubscriptions),
          IconButton(tooltip: 'Help', icon: const Icon(Icons.help), onPressed: _showHelpPage),
          IconButton(tooltip: 'Log', icon: const Icon(Icons.notes),onPressed: () {LogDisplay.show(context);})
        ],
      ),
      body: ListView(children: list)
    );
  }

  Future<void> _exit () async {
    if(await widget._controller.askToConfirm(context, 'Exit?', alwaysAsk: true)) exit(0);
  }
  
  Future<void> _showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return HelpPage(url: mainHelpURL);
    })
    );
  }

  void _share () async {
    await SharePlus.instance.share(ShareParams(files: [XFile(widget._controller._settings!.fileName)], subject: 'Boat Instrument Settings'));
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

  void _showPathSubscriptions () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _PathSubscriptionsPage(widget._controller);
    }));
  }

  void _editHttpHeaders () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _EditHttpHeaders(widget._controller._settings!.httpHeaders);
    }));
  }
}

class _PathSubscriptionsPage extends StatelessWidget {
  final BoatInstrumentController _controller;

  const _PathSubscriptionsPage(this._controller);
  
  @override
  Widget build(BuildContext context) {
    List<ListTile> list = [];

    for(var path in _controller.paths) {
      list.add(ListTile(dense: true, leading: Text(path)));
    }

    list.add(const ListTile(title: Text('Static Data', textAlign: TextAlign.center)));

    for(var path in _controller.staticPaths) {
      list.add(ListTile(dense: true, leading: Text(path)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      body: ListView(children: list)
    );
  }
}

class _EditHttpHeaders extends StatefulWidget {
  final List<_HttpHeader> _httpHeaders;

  const _EditHttpHeaders(this._httpHeaders);

  @override
  createState() => _EditHttpHeadersState();
}

class _EditHttpHeadersState extends State<_EditHttpHeaders> {

  @override
  Widget build(BuildContext context) {

    List<Widget> headerList = [];
    for(int h=0; h<widget._httpHeaders.length; ++h) {
      var header = widget._httpHeaders[h];
      headerList.add(ListTile(key: UniqueKey(),
          title: Column(children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'name'),
              initialValue: header.name,
              onChanged: (value) => header.name = value),
            TextFormField(
              decoration: const InputDecoration(hintText: 'value'),
              initialValue: header.value,
              onChanged: (value) => header.value = value)
          ]),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {_deleteHeader(h);})
      ));
      headerList.add(Divider(thickness: 3, color: Theme.of(context).colorScheme.secondary));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("HTTP Headers"),
          actions: [
            IconButton(tooltip: 'Add Header', icon: const Icon(Icons.add),onPressed:  _addHeader),
          ],
        ),
        body: ListView(children: headerList)
    );
  }

  void _addHeader() {
    setState(() {
      widget._httpHeaders.add(_HttpHeader());
    });
  }

  Future<void> _deleteHeader(int headerNum) async {
    setState(() {
      widget._httpHeaders.removeAt(headerNum);
    });
  }
}
