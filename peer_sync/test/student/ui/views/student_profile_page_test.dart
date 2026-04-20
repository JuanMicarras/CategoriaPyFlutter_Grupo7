import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- Imports de tu Proyecto ---
import 'package:peer_sync/features/student/ui/views/student_profile_page.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/auth/domain/models/auth_user.dart';

// --- FAKES ---

class FakeAuthController extends GetxController implements AuthController {
  // Simulamos un usuario observable
  final _user = Rxn<AuthUser>(AuthUser(
    tokenA: 'abc', 
    tokenR: 'def', 
    email: 'keiver@dev.com', 
    role: 'student', 
    name: 'Keiver Miranda'
  ));

  @override
  AuthUser? get user => _user.value;

  @override
  Future<void> signOut() async {
    // Simulamos la salida
  }

  @override dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('Debe mostrar la información del perfil del estudiante', (WidgetTester tester) async {
    // 1. Inyectar el controlador fake
    Get.put<AuthController>(FakeAuthController());

    // 2. Cargar la página
    await tester.pumpWidget(const GetMaterialApp(home: StudentProfilePage()));
    await tester.pump();

    // 3. Verificar que los datos del FakeAuthController se vean en pantalla
    expect(find.text('Keiver Miranda'), findsOneWidget);
    expect(find.text('keiver@dev.com'), findsOneWidget);
    
    // Verificar la inicial en el CircleAvatar
    expect(find.text('K'), findsOneWidget);
    
    // Verificar que existan los items de configuración
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('Debe mostrar el diálogo de confirmación al presionar Cerrar sesión', (WidgetTester tester) async {
    Get.put<AuthController>(FakeAuthController());

    await tester.pumpWidget(const GetMaterialApp(home: StudentProfilePage()));
    
    // 1. Buscar y presionar el botón de cerrar sesión
    final logoutButton = find.text('Cerrar sesión');
    await tester.tap(logoutButton);
    
    // 2. pumpAndSettle es necesario porque los diálogos tienen animaciones
    await tester.pumpAndSettle();

    // 3. Verificar que el diálogo de Get.defaultDialog apareció
    expect(find.text('¿Estás seguro de que quieres salir?'), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });
}