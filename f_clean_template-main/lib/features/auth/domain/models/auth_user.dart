class AuthUser {
  final String tokenA;
  final String tokenR;
  final String email;
  final String role; // 'teacher' o 'student'
  final String name;

  AuthUser({required this.tokenA,required this.tokenR, required this.email, required this.role, required this.name});
}