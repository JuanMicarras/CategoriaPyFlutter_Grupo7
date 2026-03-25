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
  final passwordError = RxnString();
  final emailError = RxnString();

  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = null;
      return;
    }

    List<String> missing = [];
    if (value.length < 8) missing.add("8 caracteres");
    if (!value.contains(RegExp(r'[A-Z]'))) missing.add("mayúscula");
    if (!value.contains(RegExp(r'[a-z]'))) missing.add("minúscula");
    if (!value.contains(RegExp(r'[0-9]'))) missing.add("número");
    if (!value.contains(RegExp(r'[!@#$_\-]'))) missing.add(r"símbolo (!@#_-$)");

    if (missing.isEmpty) {
      passwordError.value = null;
    } else {
      passwordError.value = "Falta: ${missing.join(', ')}";
    }
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = null;
      return;
    }

    if (!value.endsWith('@uninorte.edu.co')) {
      emailError.value = 'El correo debe ser @uninorte.edu.co';
    } else {
      emailError.value = null;
    }
  }

  void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
  }

  final _user = Rxn<AuthUser>();
  AuthUser? get user => _user.value;

  final obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool get isLogged => _user.value != null;

  // Método para el Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final loggedUser = await repository.signIn(email, password);

      _user.value = loggedUser;

      if (loggedUser.role == 'teacher') {
        Get.offAllNamed('/homeTeacher');
      } else {
        Get.offAllNamed('/homeStudent');
      }
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;

      final newUser = await repository.signUp(email, password, name);

      _user.value = newUser;

      if (newUser.role == 'teacher') {
        Get.offAllNamed('/homeTeacher');
      } else {
        Get.offAllNamed('/homeStudent');
      }
    } catch (e) {
      print(e.toString());

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoading.value = true;
    final savedUser = await repository.getSavedUser();

    if (savedUser != null) {
      // Si había sesión, actualizamos nuestra variable reactiva.
      // ¡Como Central.dart usa Obx, redirigirá al HomePage automáticamente!
      _user.value = savedUser;
    }
    isLoading.value = false;
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;

      await repository.clearUser();

      _user.value = null;

      Get.offAllNamed('/login');
    } catch (e) {
      print("Error al cerrar sesión: $e");
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
