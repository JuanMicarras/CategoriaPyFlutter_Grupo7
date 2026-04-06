import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/i_authentication_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthenticationSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthUser> signIn(String email, String password) async {
    final response = await _dataSource.login(email, password);
    final tokenA = response['accessToken'];
    final tokenR = response['refreshToken'];
    // print('✅ Login exitoso, : $response');
    final role = response['role'];
    final name = response['name'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenA', tokenA);
    await prefs.setString('email', email);
    await prefs.setString('tokenR', tokenR);
    await prefs.setString('name', name);
    await prefs.setString('role', role);

    return AuthUser(
      tokenA: tokenA,
      tokenR: tokenR,
      email: email,
      role: role,
      name: name,
    );
  }

  @override
  Future<AuthUser> signUp(String email, String password, String name) async {
    final response = await _dataSource.signUp(email, password, name);
    final tokenA = response['accessToken'];
    final tokenR = response['refreshToken'];
    final role = 'student';
    // 2. Guardamos también al registrarse
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenA', tokenA);
    await prefs.setString('tokenR', tokenR);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
    return AuthUser(
      tokenA: tokenA,
      tokenR: tokenR,
      email: email,
      role: role,
      name: name,
    );
  }

  // 3. Método para leer la sesión al abrir la app
  @override
  Future<AuthUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenA = prefs.getString('tokenA');
    final tokenR = prefs.getString('tokenR');
    final email = prefs.getString('email');
    final role = prefs.getString('role');
    final name = prefs.getString('name');
    print(
      '🔍 Verificando sesión guardada, tokenA: $tokenA, tokenR: $tokenR, email: $email, role: $role, name: $name',
    );
    if (tokenA != null && tokenR != null && email != null) {
      return AuthUser(
        tokenA: tokenA,
        tokenR: tokenR,
        email: email,
        role: role!,
        name: name!,
      );
    }
    return null; // No hay sesión activa
  }

  Future<String?> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('tokenR');

    if (refreshToken == null) return null;

    try {
      final response = await _dataSource.refreshToken(refreshToken);

      final newAccessToken = response['accessToken'];
      final newRefreshToken = response['refreshToken'];

      /// 🔥 Guardar nuevos tokens
      await prefs.setString('tokenA', newAccessToken);

      if (newRefreshToken != null) {
        await prefs.setString('tokenR', newRefreshToken);
      }

      print("🔄 Token refrescado correctamente");

      return newAccessToken;
    } catch (e) {
      print("❌ Error refrescando token: $e");

      /// 🔒 Si falla → logout
      await clearUser();
      return null;
    }
  }

  @override
  Future<T> safeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      if (e.toString().contains('401')) {
        print("🔄 Token expirado, intentando refresh...");

        final newToken = await refreshAccessToken();

        if (newToken != null) {
          print("✅ Reintentando request...");
          return await request(); // 🔁 retry
        } else {
          print("❌ No se pudo refrescar token");
        }
      }

      rethrow;
    }
  }

  // 4. Método para borrar la sesión al dar "Logout"
  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    print(
      'name: ${prefs.getString('name')}, email: ${prefs.getString('email')}, role: ${prefs.getString('role')}',
    );
    await prefs.remove('tokenA');
    await prefs.remove('tokenR');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('name');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }
  
}
