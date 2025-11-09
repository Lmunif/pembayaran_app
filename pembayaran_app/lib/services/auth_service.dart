import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../utils/app_navigator.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthService {
  // In-memory session cookie captured from server (e.g., "session_id=...")
  static String? _sessionCookie;

  // Allow other parts (e.g., logout) to clear stored cookie
  static void clearSession() {
    _sessionCookie = null;
  }

  // Use Android emulator host mapping, otherwise localhost
  final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8080/api'
      : 'http://127.0.0.1:8080/api';

  Future<LoginResponse> login(String username, String password) async {
    try {
      // Base headers
      var headers = {
        'Content-Type': 'application/json',
      };

      // Attach session cookie if already captured
      if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
        headers['Cookie'] = _sessionCookie!;
      }

      var request = http.Request('POST', Uri.parse('$baseUrl/login'));
      request.body = json.encode({
        "username": username,
        "password": password
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();

      // Capture Set-Cookie from response headers if present
      final setCookieHeader = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
      if (setCookieHeader != null) {
        final parsed = _parseSessionCookie(setCookieHeader);
        if (parsed != null) {
          _sessionCookie = parsed; // e.g., "session_id=..."
        }
      }

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        // Some backends may also put session_id in JSON body
        final bodySessionId = jsonResponse['session_id'];
        if (bodySessionId is String && bodySessionId.isNotEmpty) {
          _sessionCookie = 'session_id=' + bodySessionId;
        }
        return LoginResponse.fromJson(jsonResponse);
      } else {
        // Session expired or unauthorized
        if (response.statusCode == 401 || response.statusCode == 403) {
          // Avoid redirect loop for login endpoint itself
          final isLoginEndpoint = request.url.path.endsWith('/login');
          if (!isLoginEndpoint) {
            // Clear local auth state via provider
            final ctx = AppNavigator.navigatorKey.currentContext;
            if (ctx != null) {
              try {
                Provider.of<AuthProvider>(ctx, listen: false).logout();
              } catch (_) {}
            }
            // Navigate back to login
            AppNavigator.toLogin();
          }
        }
        // Try to extract meaningful message from body if provided
        try {
          final Map<String, dynamic> errJson = json.decode(responseBody);
          final String msg = (errJson['message'] ?? errJson['error'] ??
                  response.reasonPhrase ??
                  'Login failed')
              .toString();
          return LoginResponse.error(msg);
        } catch (_) {
          return LoginResponse.error(
              response.reasonPhrase ?? 'Login failed (${response.statusCode})');
        }
      }
    } catch (e) {
      return LoginResponse.error('Network error: ${e.toString()}');
    }
  }

  // Extract "session_id=..." from Set-Cookie header value
  String? _parseSessionCookie(String raw) {
    final match = RegExp(r'session_id=([^;]+)').firstMatch(raw);
    if (match != null) {
      return 'session_id=${match.group(1)}';
    }
    return null;
  }

  Future<RegisterResponse> register(String username, String email, String name, String password) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
      };

      var request = http.Request('POST', Uri.parse('$baseUrl/register'));
      request.body = json.encode(RegisterRequest(
        username: username,
        email: email,
        name: name,
        password: password,
      ).toJson());
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        return RegisterResponse.fromJson(jsonResponse);
      } else {
        try {
          final Map<String, dynamic> errJson = json.decode(responseBody);
          final String msg = (errJson['message'] ?? errJson['error'] ??
                  response.reasonPhrase ??
                  'Registration failed')
              .toString();
          throw Exception(msg);
        } catch (_) {
          throw Exception(
              response.reasonPhrase ?? 'Registration failed (${response.statusCode})');
        }
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}