class AuthUser {
  final String id;
  final String email;
  final String role; // 'teacher' o 'student'

  AuthUser({required this.id, required this.email, required this.role});
}