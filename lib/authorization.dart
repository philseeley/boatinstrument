import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef OnAuth = Function(String authToken);
typedef OnError = Function(String msg);

class SignalKAuthorization {
  late String _signalKServer;
  String? _authRequestHREF;
  late OnAuth _onAuth;
  late OnError _onError;

  void request(String signalKServer, String id, String description, OnAuth onAuth, OnError onError) async {
    _signalKServer = signalKServer;
    _onAuth = onAuth;
    _onError = onError;

    Uri uri = Uri.http(_signalKServer, '/signalk/v1/access/requests');

    http.Response response = await http.post(
        uri,
        headers: {
          "accept": "application/json",
        },
        body: {
          "clientId": id,
          "description": description}
    );

    dynamic data = json.decode(response.body);
    _authRequestHREF = data['href'];

    _checkAuhRequest();
  }

  void _checkAuhRequest () {
    Timer(const Duration(seconds: 5), _checkAuthRequestResponse);
  }

  void _checkAuthRequestResponse() async {
    Uri uri = Uri.http(_signalKServer, _authRequestHREF!);

    http.Response response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json"
      },
    );

    dynamic data = json.decode(response.body);

    if(data['state'] == 'COMPLETED') {
      if(data['statusCode'] == 200) {
        if(data['accessRequest']['permission'] == 'APPROVED') {
          _onAuth(data['accessRequest']['token']);
        } else {
          _onError('Failed: permission ${data['accessRequest']['permission']}');
        }
      } else {
        _onError('Failed: code ${data['statusCode']}');
      }
    } else {
      _checkAuhRequest();
    }
  }
}
