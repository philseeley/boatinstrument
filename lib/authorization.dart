import 'dart:async';
import 'dart:convert';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:http/http.dart' as http;

typedef OnAuth = Function(String authToken);
typedef OnError = Function(String msg);

class SignalKAuthorization {
  final BoatInstrumentController _controller;
  late OnAuth _onAuth;
  late OnError _onError;
  String? _authRequestHREF;

  SignalKAuthorization(this._controller);

  void request(String id, String description, OnAuth onAuth, OnError onError) async {
    _onAuth = onAuth;
    _onError = onError;

    try {
      // The path of the signalk-http endpoint has a 'api/' at the end that the access request does not want.
      Uri uri = _controller.httpApiUri.replace(
        path: '${_controller.httpApiUri.path.substring(0, _controller.httpApiUri.path.length-4)}access/requests');

      http.Response response = await _controller.httpPost(
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
    } catch (e) {
      _controller.l.e('Failed to send auth token request', error: e);
    }
  }

  void _checkAuhRequest () {
    Timer(const Duration(seconds: 5), _checkAuthRequestResponse);
  }

  void _checkAuthRequestResponse() async {
    try {
      Uri uri = _controller.httpApiUri.replace(path: _authRequestHREF!);

      http.Response response = await _controller.httpGet(
        uri,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json"
        },
      );

      dynamic data = json.decode(response.body);

      if (data['state'] == 'COMPLETED') {
        if (data['statusCode'] == 200) {
          if (data['accessRequest']['permission'] == 'APPROVED') {
            _onAuth(data['accessRequest']['token']);
          } else {
            _onError(
                'Failed: permission ${data['accessRequest']['permission']}');
          }
        } else {
          _onError('Failed: code ${data['statusCode']}');
        }
      } else {
        _checkAuhRequest();
      }
    } catch (e) {
      _controller.l.e('Failed to retrieve auth token response', error: e);
    }
  }
}
