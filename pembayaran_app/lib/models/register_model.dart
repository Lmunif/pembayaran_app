class RegisterRequest {
  final String username;
  final String email;
  final String name;
  final String password;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'name': name,
      'password': password,
    };
  }
}

class RegisterResponse {
  final int id;
  final String username;
  final String email;
  final String name;

  RegisterResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
    );
  }
}