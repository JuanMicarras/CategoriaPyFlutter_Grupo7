import 'package:peer_sync/features/auth/domain/models/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> signUp(String email, String password, String role);
  Future<AuthUser?> getSavedUser(); // Busca si hay sesión guardada
  Future<void> clearUser();
  Future<T> safeRequest<T>(Future<T> Function() request);
}