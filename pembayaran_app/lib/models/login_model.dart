class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  final bool success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? userData;

  LoginResponse({
    required this.success,
    this.message,
    this.token,
    this.userData,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      userData: json['user_data'],
    );
  }

  factory LoginResponse.error(String message) {
    return LoginResponse(
      success: false,
      message: message,
    );
  }
}