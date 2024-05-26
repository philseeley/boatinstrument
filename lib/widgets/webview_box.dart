import 'dart:io';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:json_annotation/json_annotation.dart';

part 'webview_box.g.dart';

@JsonSerializable()
class _Settings extends BoxSettings {
  String? url;

  _Settings({
    this.url
  });
}

class WebViewBox extends BoxWidget {

  WebViewBox(super._controller, super._constraints, {super.key});

  @override
  State<WebViewBox> createState() => _WebViewBoxState();

  static String sid = 'webview';
  @override
  String get id => sid;

  _Settings _editSettings = _Settings();

  @override
  bool get hasSettings => true;

  @override
  Widget getSettingsWidget(Map<String, dynamic> json) {
    _editSettings = _$SettingsFromJson(json);
    return _SettingsWidget(super.controller, _editSettings);
  }

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$SettingsToJson(_editSettings);
  }
}

class _WebViewBoxState extends State<WebViewBox> {
  _Settings _settings = _Settings();

  @override
  void initState() {
    super.initState();
    _settings = _$SettingsFromJson(widget.controller.configure(widget));
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isMacOS) {
      return const Center(child: Text('Not implemented on MacOS'));
    }
    if(_settings.url == null) {
      return const Center(child: Text('No Web Page set'));
    } else {
      return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_settings.url!))
      );
    }
  }
}

class _SettingsWidget extends StatefulWidget {
  final _Settings _settings;

  const _SettingsWidget(_, this._settings);

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text("Web Site:"),
          title: TextFormField(
              initialValue: s.url,
              onChanged: (value) => s.url = value)
      ),
    ]);
  }
}
