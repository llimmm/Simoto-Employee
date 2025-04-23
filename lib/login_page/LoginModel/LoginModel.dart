class LoginModel {
  final String name;
  final String password;

  LoginModel({
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'password': password,
      };
}

class LoginResponse {
  final String token;
  final String message;
  final bool success;
  final Map<String, dynamic> user;

  LoginResponse({
    required this.token,
    required this.message,
    required this.success,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['data']?['token'] ?? '', // Correctly extract the token
      message: json['message'] ?? '',
      success: json['status'] ?? false, // Ensure status maps to success
      user: json['data']?['user'] ?? {}, // Extract user data
    );
  }
}
