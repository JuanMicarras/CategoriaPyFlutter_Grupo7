import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- Imports de tu Proyecto ---
import 'package:peer_sync/features/auth/ui/views/forgot_password_page.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

// --- FAKE ---

class FakeForgotPassController extends GetxController implements AuthController {
  @override final resetEmailController = TextEditingController();
  @override final isLoading = false.obs;

  bool resetSent = false;

  @override
  Future<void> sendPasswordReset() async {
    isLoading.value = true;
    // Simular éxito
    resetSent = true;
    isLoading.value = false;
  }

  @override dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('ForgotPasswordPage debe mostrar textos de ayuda y campo de correo', (WidgetTester tester) async {
    Get.put<AuthController>(FakeForgotPassController());

    await tester.pumpWidget(const GetMaterialApp(home: ForgotPasswordPage()));

    // Verificar textos informativos
    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(find.textContaining('Ingresa el correo electrónico'), findsOneWidget);
    
    // Verificar existencia del TextField por su hint
    expect(find.text('ejemplo@uninorte.edu.co'), findsOneWidget);
  });

  testWidgets('Debe llamar a sendPasswordReset al presionar el botón', (WidgetTester tester) async {
    final authController = FakeForgotPassController();
    Get.put<AuthController>(authController);

    await tester.pumpWidget(const GetMaterialApp(home: ForgotPasswordPage()));

    // 1. Escribir un correo
    await tester.enterText(find.byType(TextField), 'test@uninorte.edu.co');
    
    // 2. Presionar el botón
    await tester.tap(find.text('Enviar enlace'));
    await tester.pump(); // Inicia el proceso (isLoading = true)

    // 3. Verificar que se llamó a la lógica
    expect(authController.resetSent, isTrue);
  });

  testWidgets('El botón debe mostrar carga cuando isLoading es true', (WidgetTester tester) async {
    final authController = FakeForgotPassController();
    Get.put<AuthController>(authController);

    await tester.pumpWidget(const GetMaterialApp(home: ForgotPasswordPage()));

    // Activar estado de carga manualmente
    authController.isLoading.value = true;
    await tester.pump();

    // El texto "Enviar enlace" no debe ser visible, debe haber un CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // El botón debería estar deshabilitado (onPressed es null cuando isLoading es true)
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}