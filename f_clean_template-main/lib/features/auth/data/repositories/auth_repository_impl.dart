import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/mock_auth_service.dart'; // Tu servicio mock

class AuthRepositoryImpl implements IAuthRepository {
  // Dependemos del Data Source, no de una implementación interna
  final MockAuthService _dataSource = MockAuthService();

  @override
  Future<AuthUser> signIn(String email, String password) async {
    // 1. Llamamos al servicio (Simulando a "Roble")
    final response = await _dataSource.loginFake(email, password);

    // 2. Mapeamos el resultado (Map/JSON) a nuestra Entidad de Dominio
    // Según el material, los Data Sources devuelven Models y el Repositorio Entities [cite: 157]
    return AuthUser(
      id: response['id'],
      email: response['email'],
      role: response['role'],
    );
  }

  @override
  Future<AuthUser> signUp(String email, String password, String role) async {
    // Por ahora, como es Mock, podemos retornar un usuario genérico tras un delay
    await Future.delayed(const Duration(seconds: 2));
    return AuthUser(id: "999", email: email, role: role);
  }
}