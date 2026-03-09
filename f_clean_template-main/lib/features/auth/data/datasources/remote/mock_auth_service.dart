class MockAuthService {
  Future<Map<String, dynamic>> loginFake(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simula latencia
    return {
      'id': '123',
      'email': email,
      'role': 'teacher', // Por ahora forzamos un rol
    };
  }
}