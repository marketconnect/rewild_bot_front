import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiHelper {
  final String _url;
  final String _host;
  DateTime? lastReq;
  static const Duration requestTimeout = Duration(seconds: 30);

  Map<String, String> headers(String token) => {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

  final int requestLimitPerMinute;

  final Map<int, String> statusCodeDescriptions;

  ApiHelper(
      {required String url,
      required String host,
      required this.requestLimitPerMinute,
      required this.statusCodeDescriptions})
      : _url = url,
        _host = host {
    // print('created ApiHelper with url $_url and host $_host');
  }

  Uri _buildUri(Map<String, String>? params) {
    return Uri.https(_host, _url, params);
  }

  String errResponse({
    required int statusCode,
  }) {
    return statusCodeDescriptions[statusCode] ??
        "Unknown error. Status code: $statusCode";
  }

  Future<void> _waitForNextRequest() async {
    final now = DateTime.now();
    if (lastReq != null) {
      final elapsedMilliseconds = now.difference(lastReq!).inMilliseconds;
      final timeToWait =
          (60 * 1000 / requestLimitPerMinute).round() - elapsedMilliseconds;

      if (timeToWait > 0) {
        await Future.delayed(Duration(milliseconds: timeToWait));
      }
    }

    lastReq = DateTime.now();
  }

  Future<http.Response> get(String? token,
      [Map<String, String>? params]) async {
    await _waitForNextRequest();
    final uri = _buildUri(params);

    final response = token != null
        ? await http.get(uri, headers: headers(token)).timeout(requestTimeout)
        : await http.get(uri).timeout(requestTimeout);
    lastReq = DateTime.now();
    return response;
  }

  Future<http.Response> post(String token, dynamic body,
      [Map<String, String>? params]) async {
    params ??= {};
    await _waitForNextRequest();
    final uri = _buildUri(params);

    final jsonString = json.encode(body);

    final resp = await http
        .post(uri, headers: headers(token), body: jsonString)
        .timeout(requestTimeout);

    lastReq = DateTime.now();

    return resp;
  }

  Future<http.Response> patch(String token, dynamic body,
      [Map<String, String>? params]) async {
    params ??= {};
    await _waitForNextRequest();
    final uri = _buildUri(params);

    final jsonString = json.encode(body);

    final resp = await http
        .patch(uri, headers: headers(token), body: jsonString)
        .timeout(requestTimeout);

    lastReq = DateTime.now();

    return resp;
  }
}
