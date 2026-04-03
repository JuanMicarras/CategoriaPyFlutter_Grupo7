abstract class IAuthenticationSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> signUp(String email, String password, String name);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);

  // Los demás métodos los dejamos para después
}