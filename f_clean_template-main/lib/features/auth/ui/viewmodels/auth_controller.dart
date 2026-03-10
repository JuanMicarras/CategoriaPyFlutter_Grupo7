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
  final isLoading = false.obs;

  final _user = Rxn<AuthUser>();
  AuthUser? get user => _user.value;

<<<<<<< HEAD
  final obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
=======
  bool get isLogged => _user.value != null;

>>>>>>> main

  // Método para el Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

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
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String role) async {
    try {
      isLoading.value = true;

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
      isLoading.value = false;
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
