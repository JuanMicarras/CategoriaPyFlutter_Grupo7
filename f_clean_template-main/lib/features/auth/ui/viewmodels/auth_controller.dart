import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/models/auth_user.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthController extends GetxController {
  final IAuthRepository repository;

  AuthController({required this.repository});

  /// 🔥 Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  /// 🔥 Estados
  final isLoading = false.obs;
  final passwordError = RxnString();
  final emailError = RxnString();

  final obscurePassword = true.obs;

  final _user = Rxn<AuthUser>();
  AuthUser? get user => _user.value;

  bool get isLogged => _user.value != null;

  /// 🔥 Timer para refresh automático
  Timer? _refreshTimer;

  /// =========================
  /// VALIDACIONES
  /// =========================

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
    if (!value.contains(RegExp(r'[!@#$_\-]'))) {
      missing.add("símbolo (!@#_-\$)");
    }

    passwordError.value =
        missing.isEmpty ? null : "Falta: ${missing.join(', ')}";
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

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// =========================
  /// 🔥 TOKEN HELPERS
  /// =========================

  int getTokenExpiration(String token) {
    final parts = token.split('.');
    final payload = parts[1];

    final normalized = base64.normalize(payload);
    final decoded = utf8.decode(base64Decode(normalized));

    final data = jsonDecode(decoded);

    return data['exp'];
  }

  /// =========================
  /// 🔥 AUTO REFRESH INTELIGENTE
  /// =========================

  void startAutoRefresh() {
    final repo = repository as AuthRepositoryImpl;

    _refreshTimer?.cancel();

    final token = user?.tokenA;

    if (token == null) return;

    final exp = getTokenExpiration(token);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    /// 🔥 refrescar 2 min antes
    final refreshTime = (exp - now - 120).clamp(0, 999999);

    print("⏳ Token expira en: ${exp - now}s");
    print("🔄 Refresh programado en: $refreshTime segundos");

    _refreshTimer = Timer(Duration(seconds: refreshTime), () async {
      print("🔄 Ejecutando refresh automático...");

      final newToken = await repo.refreshAccessToken();

      if (newToken != null) {
        /// 🔁 reprogramar con nuevo token
        startAutoRefresh();
      } else {
        print("❌ Sesión expirada → login");
        Get.offAllNamed('/login');
      }
    });
  }

  /// =========================
  /// 🔐 LOGIN
  /// =========================

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final loggedUser = await repository.signIn(email, password);

      _user.value = loggedUser;

      print(
        '✅ Usuario logueado: tokenA: ${loggedUser.tokenA}, tokenR: ${loggedUser.tokenR}',
      );

      /// 🔥 iniciar auto refresh
      startAutoRefresh();

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

  /// =========================
  /// 📝 SIGN UP
  /// =========================

  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;

      final newUser = await repository.signUp(email, password, name);

      _user.value = newUser;

      /// 🔥 iniciar auto refresh
      startAutoRefresh();

      if (newUser.role == 'teacher') {
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

  /// =========================
  /// 🔄 INIT
  /// =========================

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoading.value = true;

    final savedUser = await repository.getSavedUser();

    if (savedUser != null) {
      _user.value = savedUser;

      /// 🔥 iniciar auto refresh si ya estaba logueado
      startAutoRefresh();
    }

    isLoading.value = false;
  }

  /// =========================
  /// 🚪 LOGOUT
  /// =========================

  Future<void> signOut() async {
    try {
      isLoading.value = true;

      _refreshTimer?.cancel();

      await repository.clearUser();

      _user.value = null;

      Get.offAllNamed('/login');
    } catch (e) {
      print("Error al cerrar sesión: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================
  /// 🔚 DISPOSE
  /// =========================

  @override
  void onClose() {
    _refreshTimer?.cancel();

    emailController.dispose();
    passwordController.dispose();

    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();

    super.onClose();
  }
}
