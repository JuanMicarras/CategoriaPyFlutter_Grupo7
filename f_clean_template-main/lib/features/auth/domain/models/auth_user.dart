class AuthUser {
  final String tokenA;
  final String tokenR;
  final String email;
  final String role; // 'teacher' o 'student'
  final String name;

  AuthUser({required this.tokenA,required this.tokenR, required this.email, required this.role, required this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      tokenA: json['accessToken'], 
      tokenR: json['refreshToken'], 
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }
}