import 'dart:io';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:json_annotation/json_annotation.dart';

part 'webview_box.g.dart';

@JsonSerializable()
class _Settings {
  String url = '';

  _Settings(this.url);
}
//TODO the view isn't scrollable. Do we want it to be? Do we want it to be more browser like?
class WebViewBox extends BoxWidget {
  late _Settings _settings;

  WebViewBox(super._controller, settingsJson, super._constraints, {super.key}) {
    _settings = _$SettingsFromJson(settingsJson);
  }

  @override
  State<WebViewBox> createState() => _WebViewBoxState();

  static String sid = 'webview';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  Widget getPerBoxSettingsWidget() {
    return _SettingsWidget(_settings);
  }

  @override
  Map<String, dynamic> getPerBoxSettingsJson() {
    return _$SettingsToJson(_settings);
  }
}

class _WebViewBoxState extends State<WebViewBox> {

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget);
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isMacOS) {
      return const Center(child: Text('Not implemented on MacOS'));
    }
    if(widget._settings.url.isEmpty) {
      return const Center(child: Text('No Web Page set'));
    } else {
      return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget._settings.url!))
      );
    }
  }
}

class _SettingsWidget extends StatefulWidget {
  final _Settings _settings;

  const _SettingsWidget(this._settings);

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
              onChanged: (value) => s.url = value.trim())
      ),
    ]);
  }
}
