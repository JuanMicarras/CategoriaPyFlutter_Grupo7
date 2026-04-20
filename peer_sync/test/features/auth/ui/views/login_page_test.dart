import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- Imports de tu Proyecto ---
import 'package:peer_sync/features/auth/ui/views/login_page.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

// --- FAKE ---

class FakeLoginAuthController extends GetxController implements AuthController {
  @override
  final emailController = TextEditingController();
  @override
  final passwordController = TextEditingController();

  @override
  final emailError = RxnString();
  @override
  final passwordError = RxnString();
  @override
  final isLoading = false.obs;

  final obscurePassword = true.obs;

  @override
  bool get canSubmitLogin =>
      emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

  @override
  void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
  }

  // Si tu AuthTextField permite conmutar el ojo de la contraseña,
  // añade también este método si el interface lo requiere:
  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  Future<void> login(String email, String password) async {
    isLoading.value = true;
  }

  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('LoginPage debe cargar con valores iniciales y limpiar errores', (
    WidgetTester tester,
  ) async {
    final authController = FakeLoginAuthController();
    Get.put<AuthController>(authController);

    await tester.pumpWidget(GetMaterialApp(home: LoginPage()));
    // Esperamos al frame callback del constructor
    await tester.pump();

    // Verificar que el constructor seteó la contraseña por defecto
    expect(authController.passwordController.text, 'ThePassword!1');
    expect(find.text('Inicia Sesión'), findsOneWidget);
  });

  testWidgets(
    'Debe mostrar error cuando el controlador tiene mensajes de error',
    (WidgetTester tester) async {
      final authController = FakeLoginAuthController();
      Get.put<AuthController>(authController);

      await tester.pumpWidget(GetMaterialApp(home: LoginPage()));

      // Simular un error de backend/validación
      authController.emailError.value = 'Correo inválido';
      await tester.pump();

      expect(find.text('Correo inválido'), findsOneWidget);
    },
  );

  testWidgets(
    'El botón debe estar deshabilitado si el formulario está incompleto',
    (WidgetTester tester) async {
      final authController = FakeLoginAuthController();
      Get.put<AuthController>(authController);

      await tester.pumpWidget(GetMaterialApp(home: LoginPage()));

      // Limpiamos los campos (el constructor pone uno por defecto)
      authController.emailController.clear();
      authController.passwordController.clear();
      await tester.pump();

      final loginButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(loginButton.onPressed, isNull); // Deshabilitado
    },
  );

  testWidgets(
    'Debe mostrar CircularProgressIndicator cuando isLoading es true',
    (WidgetTester tester) async {
      final authController = FakeLoginAuthController();
      Get.put<AuthController>(authController);

      await tester.pumpWidget(GetMaterialApp(home: LoginPage()));

      authController.isLoading.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('Debe navegar a Registro al presionar "Regístrate"', (
    WidgetTester tester,
  ) async {
    Get.put<AuthController>(FakeLoginAuthController());

    // Configuramos rutas para probar navegación
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => LoginPage()),
          GetPage(
            name: '/signup',
            page: () => const Scaffold(body: Text('Pantalla Registro')),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    expect(find.text('Pantalla Registro'), findsOneWidget);
  });
}
