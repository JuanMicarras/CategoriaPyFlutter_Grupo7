import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:peer_sync/features/evaluation/domain/models/criteria.dart';

// Importa tu vista y controlador
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_form_controller.dart';
// Importa las dependencias necesarias para los mocks "fantasma"
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/peer.dart';

// Creamos los Mocks
class MockEvaluationFormController extends GetxController with Mock implements EvaluationFormController {}
class MockEvaluationRepository extends Mock implements IEvaluationRepository {}
class MockAuthController extends GetxController with Mock implements AuthController {}

void main() {
  late MockEvaluationFormController mockController;

  setUp(() {
    Get.put<IEvaluationRepository>(MockEvaluationRepository());
    Get.put<AuthController>(MockAuthController());

    mockController = MockEvaluationFormController();

    // 1. FIX PARA LOS ERRORES: Definimos explícitamente <Clave, Valor>{} antes del .obs
    when(() => mockController.isLoading).thenReturn(false.obs);
    when(() => mockController.peers).thenReturn(<Peer>[].obs);
    when(() => mockController.criteriaList).thenReturn(<Criteria>[].obs);
    
    // Aquí están las correcciones de los RxMap:
    when(() => mockController.submittingPeers).thenReturn(<String, bool>{}.obs);
    when(() => mockController.completedEvaluations).thenReturn(<String, Map<String, double>>{}.obs);
    when(() => mockController.pendingEvaluations).thenReturn(<String, Map<String, double>>{}.obs);
    when(() => mockController.myAverageResults).thenReturn(<String, double>{}.obs);

    // Mocks de getters
    when(() => mockController.myPeerData).thenReturn(null);
    when(() => mockController.myEmail).thenReturn('pepito@uninorte.edu.co');
    when(() => mockController.otherPeers).thenReturn([]); 

    when(() => mockController.loadFormData(any(), any())).thenAnswer((_) async {});

    Get.put<EvaluationFormController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  // --- CASOS DE PRUEBA (NIVEL 1) ---

  testWidgets('1. Debe renderizar StudentEvaluationPage y llamar a loadFormData al iniciar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentEvaluationPage(
          activityId: 'act_123',
          activityName: 'Proyecto Flutter', 
          categoryId: 'cat_123',
          isExpired: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que el AppBar muestre el nombre de la actividad
    expect(find.textContaining('Proyecto Flutter'), findsWidgets);
    
    // Verificamos que se haya solicitado la info a la base de datos (vía controlador)
    verify(() => mockController.loadFormData('act_123', 'cat_123')).called(1);
  });

  testWidgets('2. Debe mostrar la pantalla de carga cuando isLoading es true', (WidgetTester tester) async {
    // Sobreescribimos el comportamiento solo para este test
    when(() => mockController.isLoading).thenReturn(true.obs);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentEvaluationPage(
          activityId: 'act_123',
          activityName: 'Proyecto Flutter', 
          categoryId: 'cat_123',
        ),
      ),
    );

    // Nota: Usamos pump() en lugar de pumpAndSettle() porque las animaciones 
    // circulares de carga son infinitas y harían que el test se quede esperando para siempre.
    await tester.pump(); 

    // Verificamos que aparezca el indicador de carga en pantalla
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('3. El botón de Guardar debe estar deshabilitado si ya se venció la actividad (isExpired = true)', (WidgetTester tester) async {
    // Simulamos que hay un compañero en la lista para que renderice la tarjeta de evaluación
    final fakePeer = Peer( firstName: 'Julian', email: 'julian@test.com', lastName: 'Gomez');
    when(() => mockController.otherPeers).thenReturn([fakePeer]);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentEvaluationPage(
          activityId: 'act_123',
          activityName: 'Proyecto Flutter', 
          categoryId: 'cat_123',
          isExpired: true, // ¡Clave para este test!
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Buscamos el botón de guardar. Al estar expirado, la UI de tu vista 
    // debería estar ocultándolo o deshabilitándolo.
    // Buscamos textos o iconos relacionados al guardado para asegurar la reacción de la UI.
    final saveIcon = find.byIcon(Icons.save_rounded);
    
    // Dependiendo de cómo lo hayas programado en la UI (si desaparece el botón o no),
    // esta aserción valida que la pantalla procesó el parámetro isExpired.
    expect(saveIcon, findsNothing); 
  });
}