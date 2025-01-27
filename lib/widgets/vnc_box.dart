import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rfb/flutter_rfb.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vnc_box.g.dart';

@JsonSerializable()
class _VNCSettings {
  String host;
  int port;
  String password;

  _VNCSettings({
    this.host = '',
    this.port = 5900,
    this.password = ''
  });
}

class VNCBox extends BoxWidget {
  late final _VNCSettings _settings;

  static String sid = 'vnc';
  @override
  String get id => sid;


  VNCBox(super.config, {super.key}) {
    _settings = _$VNCSettingsFromJson(config.settings);
  }

  @override
  State<VNCBox> createState() => _VNCBoxState();

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _VNCSettingsWidget(_settings);
  }
}

class _VNCBoxState extends State<VNCBox> {
  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('VNC ${widget._settings.host}:${widget._settings.port}'),
      if(!widget.config.editMode) Expanded(child: RemoteFrameBufferWidget(
        hostName: widget._settings.host,
        port: widget._settings.port,
        onError: (final Object e) {
          String msg = 'Error connecting to ${widget._settings.host}:${widget._settings.port}';
          widget.config.controller.l.e(msg, error: e);
          widget.config.controller.showMessage(context, '$msg $e', error: true);
        },
        password: widget._settings.password.isEmpty ? null : widget._settings.password
      ))
    ]);
  }
}

class _VNCSettingsWidget extends BoxSettingsWidget {
  final _VNCSettings _settings;

  const _VNCSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$VNCSettingsToJson(_settings);
  }

  @override
  createState() => _VNCSettingsState();
}

class _VNCSettingsState extends State<_VNCSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    _VNCSettings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text('Host:'),
          title: TextFormField(
              initialValue: s.host,
              onChanged: (value) => s.host = value)
      ),
      ListTile(
          leading: const Text("Port:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: s.port.toString(),
              onChanged: (value) => s.port = int.parse(value)),
      ),
      ListTile(
          leading: const Text('Password:'),
          title: TextFormField(
              initialValue: s.password,
              onChanged: (value) => s.password = value)
      ),
    ]);
  }
}
