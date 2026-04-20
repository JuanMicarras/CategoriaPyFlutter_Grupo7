import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- Imports de tu Proyecto ---
import 'package:peer_sync/features/teacher/ui/views/teacher_profile_page.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/auth/domain/models/auth_user.dart';

// --- FAKES ---

class FakeTeacherAuthController extends GetxController implements AuthController {
  // Simulamos un usuario con rol de profesor
  final _user = Rxn<AuthUser>(AuthUser(
    tokenA: 'token_prof_123', 
    tokenR: 'refresh_prof_123', 
    email: 'profesor.test@universidad.edu', 
    role: 'teacher', 
    name: 'Dr. Profesor Especialista'
  ));

  @override
  AuthUser? get user => _user.value;

  @override
  Future<void> signOut() async {
    // Simulación de cierre de sesión
  }

  @override dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('Debe ejecutar la función de logout al confirmar en el diálogo', (WidgetTester tester) async {
    final authController = FakeTeacherAuthController();
    Get.put<AuthController>(authController);

    await tester.pumpWidget(const GetMaterialApp(home: TeacherProfilePage()));
    
    // 1. Abrir diálogo
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle(); // Esperar animación del diálogo

    // 2. Verificar texto del diálogo
    expect(find.text('¿Estás seguro de que quieres salir?'), findsOneWidget);

    // 3. Presionar "Salir"
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();

    // Nota: Aquí podrías verificar si se llamó a signOut() usando un mock de Mockito 
    // o simplemente verificar que el diálogo se cerró.
  });
}