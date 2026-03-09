import 'package:peer_sync/features/auth/domain/models/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> signUp(String email, String password, String role);
}