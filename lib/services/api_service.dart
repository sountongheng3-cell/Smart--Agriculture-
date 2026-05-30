import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // GET Request
  static Future<dynamic> getRequest(
    String url,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load data',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // POST Request
  static Future<dynamic> postRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),

        headers: {
          'Content-Type': 'application/json',
        },

        body: jsonEncode(body),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to submit data',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}