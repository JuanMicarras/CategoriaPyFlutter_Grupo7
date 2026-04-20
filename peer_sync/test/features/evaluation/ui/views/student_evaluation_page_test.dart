import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:peer_sync/features/evaluation/domain/models/criteria.dart';
import 'package:peer_sync/features/evaluation/domain/models/peer.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_form_controller.dart';

// ----------------------
// Mocks
// ----------------------
class MockEvaluationFormController extends GetxController
    with Mock
    implements EvaluationFormController {}

class MockEvaluationRepository extends Mock implements IEvaluationRepository {}

class MockAuthController extends GetxController
    with Mock
    implements AuthController {}

void main() {
  late MockEvaluationFormController mockController;

  setUp(() {
    Get.put<IEvaluationRepository>(MockEvaluationRepository());
    Get.put<AuthController>(MockAuthController());

    mockController = MockEvaluationFormController();

    // ----------------------
    // Observables obligatorios
    // ----------------------
    when(() => mockController.isLoading).thenReturn(false.obs);
    when(() => mockController.peers).thenReturn(<Peer>[].obs);
    when(() => mockController.criteriaList).thenReturn(<Criteria>[].obs);
    when(() => mockController.submittingPeers).thenReturn(<String, bool>{}.obs);
    when(() => mockController.completedEvaluations).thenReturn(<String, Map<String, double>>{}.obs);
    when(() => mockController.pendingEvaluations).thenReturn(<String, Map<String, double>>{}.obs);
    when(() => mockController.myAverageResults).thenReturn(<String, double>{}.obs);

    // ----------------------
    // Datos de ejemplo
    // ----------------------
    when(() => mockController.myPeerData).thenReturn(
      Peer(firstName: 'Juan', lastName: 'Perez', email: 'juan@test.com'),
    );
    when(() => mockController.myEmail).thenReturn('pepito@uninorte.edu.co');
    when(() => mockController.otherPeers).thenReturn([]);

    // ----------------------
    // Métodos mockeados
    // ----------------------
    when(() => mockController.loadFormData(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockController.formatName(any(), any()))
        .thenAnswer((invocation) {
      final first = invocation.positionalArguments[0] as String;
      final last = invocation.positionalArguments[1] as String;
      return '$first $last';
    });
    when(() => mockController.getEvaluationStatusText(any(), any()))
        .thenReturn('Pendiente');
    when(() => mockController.getMyScoreText(any()))
        .thenReturn('5.0');
    when(() => mockController.myGeneralScore).thenReturn('5.0');
    when(() => mockController.isPeerSubmitting(any()))
        .thenReturn(false);
    when(() => mockController.getSavedScoreForPeer(any(), any()))
        .thenReturn(5.0);
    when(() => mockController.updateScoreForPeer(any(), any()))
        .thenReturn(null);
    when(() => mockController.submitEvaluationForPeer(any(), any(), any()))
        .thenAnswer((_) async {});

    Get.put<EvaluationFormController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  // ----------------------
  // Tests
  // ----------------------

  testWidgets(
    '1. Debe renderizar StudentEvaluationPage y llamar a loadFormData al iniciar',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: StudentEvaluationPage(
            activityId: 'act_123',
            activityName: 'Proyecto Flutter',
            categoryId: 'cat_123',
            visibility: true,
            isExpired: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Proyecto Flutter'), findsWidgets);
      verify(() => mockController.loadFormData('act_123', 'cat_123')).called(1);
    },
  );

  testWidgets(
    '2. Debe mostrar la pantalla de carga cuando isLoading es true',
    (WidgetTester tester) async {
      when(() => mockController.isLoading).thenReturn(true.obs);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: StudentEvaluationPage(
            activityId: 'act_123',
            activityName: 'Proyecto Flutter',
            categoryId: 'cat_123',
            visibility: true,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    },
  );

  testWidgets(
    '3. El botón de Guardar debe estar deshabilitado si ya se venció la actividad (isExpired = true)',
    (WidgetTester tester) async {
      final fakePeer = Peer(
        firstName: 'Julian',
        lastName: 'Gomez',
        email: 'julian@test.com',
      );
      when(() => mockController.otherPeers).thenReturn([fakePeer]);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: StudentEvaluationPage(
            activityId: 'act_123',
            activityName: 'Proyecto Flutter',
            categoryId: 'cat_123',
            visibility: true,
            isExpired: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar evaluación');
      expect(saveButton, findsNothing); // El botón no debe aparecer
    },
  );
}
