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
  final int? id;
  final String? username;
  final String? email;
  final String? name;

  RegisterResponse({
    this.id,
    this.username,
    this.email,
    this.name,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Dukung skema: { ... } atau { "data": { ... } }
    final Map<String, dynamic> src =
        json['data'] is Map<String, dynamic> ? json['data'] : json;

    int? parseId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return RegisterResponse(
      id: parseId(src['id']),
      username: src['username']?.toString(),
      email: src['email']?.toString(),
      name: src['name']?.toString(),
    );
  }
}