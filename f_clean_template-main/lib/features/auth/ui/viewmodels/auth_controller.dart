import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/models/auth_user.dart';

class AuthController extends GetxController {
  final IAuthRepository repository;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  AuthController({required this.repository});

  // Estados reactivos
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _user = Rxn<AuthUser>();
  AuthUser? get user => _user.value;

  bool get isLogged => _user.value != null;

  // Método para el Login
  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;

      // Llamamos al repositorio (que por ahora es Mock)
      final loggedUser = await repository.signIn(email, password);

      _user.value = loggedUser;

      // Navegación limpia con GetX al Home
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Credenciales incorrectas',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String role) async {
    try {
      _isLoading.value = true;

      // Llamamos al repositorio que implementaste previamente
      final newUser = await repository.signUp(email, password, role);

      _user.value = newUser;

      // Navegación limpia con GetX al Home tras registrarse exitosamente
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear la cuenta',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();

    super.onClose();
  }
}
