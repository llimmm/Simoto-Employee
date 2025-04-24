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
    Map<String, dynamic> userData = json['data']?['user'] ?? {};
    
    // If name is missing in the user data but present in the data section
    if ((!userData.containsKey('name') || userData['name'] == null || userData['name'].isEmpty) &&
        json['data'] != null && json['data']['name'] != null) {
      userData['name'] = json['data']['name'];
    }
    
    return LoginResponse(
      token: json['data']?['token'] ?? '',
      message: json['message'] ?? '',
      success: json['status'] ?? false,
      user: userData,
    );
  }
}