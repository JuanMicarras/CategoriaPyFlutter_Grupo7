import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- Imports de tu Proyecto ---
import 'package:peer_sync/features/auth/ui/views/signup_page.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

// --- FAKE ---
class FakeSignUpAuthController extends GetxController implements AuthController {
  @override final signUpNameController = TextEditingController();
  @override final signUpEmailController = TextEditingController();
  @override final signUpPasswordController = TextEditingController();

  @override final emailError = RxnString();
  @override final passwordError = RxnString();
  @override final isLoading = false.obs;
  @override final obscurePassword = true.obs;

  @override
  bool get canSubmitSignUp =>
      signUpNameController.text.isNotEmpty &&
      signUpEmailController.text.isNotEmpty &&
      signUpPasswordController.text.isNotEmpty;

  @override
  void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
  }

  @override
  Future<void> signUp(String email, String password, String name) async {
    isLoading.value = true;
  }

  @override dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('SignUpPage debe renderizar todos los campos y el botón', (WidgetTester tester) async {
    Get.put<AuthController>(FakeSignUpAuthController());

    await tester.pumpWidget(GetMaterialApp(home: SignUpPage()));

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Registrarse'), findsOneWidget);
  });

  testWidgets('El botón debe estar deshabilitado si faltan campos', (WidgetTester tester) async {
    final controller = FakeSignUpAuthController();
    Get.put<AuthController>(controller);

    await tester.pumpWidget(GetMaterialApp(home: SignUpPage()));

    // Inicialmente vacíos
    final signUpButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(signUpButton.onPressed, isNull);

    // Llenamos solo uno
    controller.signUpNameController.text = "Keiver Miranda";
    await tester.pump();
    
    final signUpButtonStillDisabled = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(signUpButtonStillDisabled.onPressed, isNull);
  });

  testWidgets('Debe navegar a Login al presionar "Inicia sesión"', (WidgetTester tester) async {
    Get.put<AuthController>(FakeSignUpAuthController());

    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/signup',
      getPages: [
        GetPage(name: '/signup', page: () => SignUpPage()),
        GetPage(name: '/login', page: () => const Scaffold(body: Text('Vista Login'))),
      ],
    ));

    await tester.tap(find.text('Inicia sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Vista Login'), findsOneWidget);
  });
}