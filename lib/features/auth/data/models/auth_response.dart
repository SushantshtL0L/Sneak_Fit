class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String username;
  final String role;
  final String? name;
  final String? profileImage;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.username,
    required this.role,
    this.name,
    this.profileImage,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    return AuthResponse(
      token: json['token'] ?? '',
      userId: userData['_id'] ?? userData['id'] ?? '',
      email: userData['email'] ?? '',
      username: userData['username'] ?? '',
      role: userData['role'] ?? 'user',
      name: userData['name'],
      profileImage: userData['image'],
    );
  }
}
