import 'dart:io';
import 'dart:convert';
//TODO import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  bool enableLock;
  int lockSeconds;
  String authToken;

  static File? _store;

  Settings({
    this.enableLock = true,
    this.lockSeconds = 5,
    this.authToken = "",
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
    _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static load() async {
    // TODO
    // Directory directory = await path_provider.getApplicationDocumentsDirectory();
    // _store = File('${directory.path}/settings.json');
    _store = File('settings.json');

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