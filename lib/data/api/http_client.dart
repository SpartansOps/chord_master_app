import 'dart:convert';

import 'package:http/http.dart' as http;

class CustomHttp {
  String baseUrl;

  CustomHttp({required this.baseUrl});

  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.post(Uri.parse(baseUrl + endpoint),
        headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) {
    return http.get(Uri.parse(baseUrl + endpoint), headers: headers);
  }
}
