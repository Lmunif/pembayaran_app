import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<LoginResponse> login(String username, String password) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      var request = http.Request('POST', Uri.parse('$baseUrl/login'));
      request.body = json.encode({
        "username": username,
        "password": password
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      
      String responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        return LoginResponse.fromJson(jsonResponse);
      } else {
        return LoginResponse.error(response.reasonPhrase ?? 'Login failed');
      }
    } catch (e) {
      return LoginResponse.error('Network error: ${e.toString()}');
    }
  }
}