class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String username;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    return AuthResponse(
      token: json['token'] ?? '',
      userId: userData['_id'] ?? userData['id'] ?? '',
      email: userData['email'] ?? '',
      username: userData['username'] ?? '',
    );
  }
}
