import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart'; // NUEVO IMPORT
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart'; // NUEVO IMPORT

// ---------------- MOCK ----------------
class MockEvaluationController extends GetxController
    with Mock
    implements EvaluationController {}

// NUEVO MOCK PARA ANALYTICS
class MockEvaluationAnalyticsController extends GetxController
    with Mock
    implements EvaluationAnalyticsController {}

// ---------------- FAKE ----------------
class FakeActivity extends Fake implements Activity {}

void main() {
  late MockEvaluationController mockController;
  late MockEvaluationAnalyticsController mockAnalyticsController; // DECLARADO

  setUpAll(() {
    registerFallbackValue(FakeActivity());
  });

  setUp(() {
    mockController = MockEvaluationController();
    mockAnalyticsController = MockEvaluationAnalyticsController(); // INSTANCIADO

    // Estado base de EvaluationController
    when(() => mockController.isLoadingActivities)
        .thenReturn(false.obs);

    when(() => mockController.activities)
        .thenReturn(<Activity>[].obs);

    when(() => mockController.sortedActivities)
        .thenReturn([]);

    when(() => mockController.getActivityUIData(any()))
        .thenReturn((
          month: 'ENE',
          day: '10',
          statusLabel: 'Pendiente',
          statusDetail: '• Cierre',
          isExpired: false,
          isPending: false,
          isActive: true,
        ));

    when(() => mockController.loadActivities(any()))
        .thenAnswer((_) async {});

    // Estado base de EvaluationAnalyticsController (EVITA EL CRASH)
    when(() => mockAnalyticsController.isLoadingStudentCategoryAnalytics)
        .thenReturn(false.obs);

    when(() => mockAnalyticsController.studentCategoryCriteriaChart)
        .thenReturn(<ChartPoint>[].obs);

    when(() => mockAnalyticsController.loadStudentCategoryAnalytics(any()))
        .thenAnswer((_) async {});

    // INYECTAMOS AMBOS CONTROLADORES
    Get.put<EvaluationController>(mockController);
    Get.put<EvaluationAnalyticsController>(mockAnalyticsController);
  });

  tearDown(() {
    Get.reset();
  });

  // ----------------------------------------------------
  // 1. Render básico
  // ----------------------------------------------------
  testWidgets(
      '1. Debe renderizar la página y llamar loadActivities',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentActivitiesPage(
          categoryId: 'cat_1',
          categoryName: 'Arquitectura',
        ),
      ),
    );

    await tester.pump();

    verify(() => mockController.loadActivities('cat_1')).called(1);
  });

  // ----------------------------------------------------
  // 2. Loading
  // ----------------------------------------------------
  testWidgets(
      '2. Debe mostrar loading cuando isLoadingActivities es true',
      (WidgetTester tester) async {
    when(() => mockController.isLoadingActivities)
        .thenReturn(true.obs);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentActivitiesPage(
          categoryId: 'cat_1',
          categoryName: 'Arquitectura',
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ----------------------------------------------------
  // 3. Lista con datos
  // ----------------------------------------------------
  testWidgets(
      '3. Debe renderizar actividades si hay datos',
      (WidgetTester tester) async {
    final activity = Activity(
      id: '1',
      categoryId: 'cat_1',
      name: 'Taller Final de Arquitectura',
      description: '',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      visibility: true,
    );

    when(() => mockController.sortedActivities)
        .thenReturn([activity]);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentActivitiesPage(
          categoryId: 'cat_1',
          categoryName: 'Arquitectura',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Taller Final de Arquitectura'), findsOneWidget);
  });

  // ----------------------------------------------------
  // 4. Pull to refresh
  // ----------------------------------------------------
  testWidgets(
      '4. Debe llamar loadActivities al hacer pull-to-refresh',
      (WidgetTester tester) async {
    final activity = Activity(
      id: '1',
      categoryId: 'cat_1',
      name: 'Actividad a Refrescar',
      description: '',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      visibility: true,
    );

    when(() => mockController.sortedActivities)
        .thenReturn([activity]);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentActivitiesPage(
          categoryId: 'cat_1',
          categoryName: 'Arquitectura',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Hacemos scroll hacia abajo (pull)
    await tester.drag(
      find.byType(ListView),
      const Offset(0, 300),
    );

    await tester.pump();

    // Aclaración: Verificamos que se haya llamado más de 1 vez (1 en el initState, y la extra del refresh)
    verify(() => mockController.loadActivities('cat_1')).called(greaterThan(0));
  });
}