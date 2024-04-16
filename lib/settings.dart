import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  bool enableLock;
  int lockSeconds;
  int valueSmoothing;
  String signalkServer;
  String clientID;
  String authToken;

  static File? _store;

  Settings({
    this.enableLock = true,
    this.lockSeconds = 5,
    this.valueSmoothing = 0,
    this.signalkServer = 'openplotter.local:3000',
    this.clientID = 'sailingapp-1234', //TODO gen a GUID
    this.authToken = "",
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
    _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    try {
      String? s = _store?.readAsStringSync();
      dynamic data = json.decode(s ?? "");

      return Settings.fromJson(data);
    } on Exception {
      return Settings();
    } on Error {
      return Settings();
    }
  }

  save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}
