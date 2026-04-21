import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
// Importaciones de tu proyecto
import 'package:peer_sync/features/category/ui/views/category_detail_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/features/category/ui/widgets/create_activity_modal.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
// --- FAKES Y MOCKS ---
class FakeBuildContext extends Fake implements BuildContext {}

// NUEVO: Fake para el modelo Activity
class FakeActivity extends Fake implements Activity {}

class MockEvaluationController extends GetxController
    with Mock
    implements EvaluationController {}

// NUEVO: Crea el mock para Analytics
class MockEvaluationAnalyticsController extends GetxController
    with Mock
    implements EvaluationAnalyticsController {}

void main() {
  late MockEvaluationController mockController;
  late MockEvaluationAnalyticsController mockAnalyticsController;

  setUpAll(() {
    // Registramos ambos fallbacks
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeActivity());
  });

  setUp(() {
    mockController = MockEvaluationController();
    mockAnalyticsController = MockEvaluationAnalyticsController();

    // 1. MOCKS DE ESTADOS REACTIVOS
    when(() => mockController.isLoadingTeacherActivities).thenReturn(false.obs);
    when(() => mockController.teacherActivities).thenReturn(<Activity>[].obs);
    when(() => mockController.isVisible).thenReturn(true.obs);
    when(() => mockController.isLoading).thenReturn(false.obs);

    // 2. MOCKS DE CONTROLADORES DE TEXTO
    when(() => mockController.nameController).thenReturn(TextEditingController());
    when(() => mockController.descriptionController).thenReturn(TextEditingController());
    when(() => mockController.startDateController).thenReturn(TextEditingController());
    when(() => mockController.endDateController).thenReturn(TextEditingController());
    when(() => mockController.startTimeController).thenReturn(TextEditingController());
    when(() => mockController.endTimeController).thenReturn(TextEditingController());

    // 3. MOCKS DE MÉTODOS Y CARGA
    when(() => mockController.loadTeacherActivities(any())).thenAnswer((_) async {});
    when(() => mockController.saveActivity(any())).thenAnswer((_) async => true);
    
    when(() => mockController.pickStartDate(any())).thenAnswer((_) async {});
    when(() => mockController.pickEndDate(any())).thenAnswer((_) async {});
    when(() => mockController.pickStartTime(any())).thenAnswer((_) async {});
    when(() => mockController.pickEndTime(any())).thenAnswer((_) async {});

    // --- NUEVO: CONFIGURACIONES DEL ANALYTICS CONTROLLER ---
    
    // 1. Simular la variable reactiva de la gráfica (Devuelve una lista vacía observable)
    when(() => mockAnalyticsController.teacherCategoryCriteriaChart)
        .thenReturn(<ChartPoint>[].obs); 

    // 2. Simular el método de carga en el initState (Devuelve un Future vacío)
    when(() => mockAnalyticsController.loadTeacherCategoryAnalytics(any()))
        .thenAnswer((_) async {});
    
    when(() => mockAnalyticsController.isLoadingTeacherCategoryAnalytics)
        .thenReturn(false.obs);

    Get.put<EvaluationController>(mockController);
    Get.put<EvaluationAnalyticsController>(mockAnalyticsController);
  });

  tearDown(() {
    Get.reset();
  });

  // ----------------------------------------------------
  // TEST 1: ESTADO DE CARGA
  // ----------------------------------------------------
  testWidgets('1. Debe mostrar un indicador de carga mientras carga actividades', (WidgetTester tester) async {
    
    // 1. Ambas variables deben ser true para que se cumpla el if(&&)
    when(() => mockController.isLoadingTeacherActivities).thenReturn(true.obs);
    when(() => mockAnalyticsController.isLoadingTeacherCategoryAnalytics).thenReturn(true.obs);

    // 2. Construimos la app
    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    // 3. Empujón vital de GetX
    await tester.pump();

    // 4. Verificación
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ----------------------------------------------------
  // TEST 2: LISTA VACÍA
  // ----------------------------------------------------
  testWidgets('2. Debe mostrar mensaje de lista vacía cuando no hay actividades', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    await tester.pump();

    expect(find.textContaining("No hay actividades creadas aún"), findsOneWidget);
    verify(() => mockController.loadTeacherActivities('1')).called(1);
  });

  // ----------------------------------------------------
  // TEST 3: LISTA CON DATOS
  // ----------------------------------------------------
  testWidgets('3. Debe renderizar la lista de actividades correctamente', (WidgetTester tester) async {
    final mockActivity = Activity(
      id: 'act_1',
      categoryId: 'cat_123',
      name: 'Exposición Final',
      description: 'Test Description',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1)),
      visibility: true,
    );

    when(() => mockController.teacherActivities).thenReturn(<Activity>[mockActivity].obs);
    
    // Ahora el any() de Activity funcionará por el registerFallbackValue
    when(() => mockController.getTeacherActivityUIData(any())).thenReturn((
      month: 'ABR',
      day: '08',
      statusTag: 'En curso',
      statusDetail: '• Cierra 10:00 PM',
      isExpired: false,
    ));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Exposición Final'), findsOneWidget);
    expect(find.text('En curso'), findsOneWidget);
    expect(find.byType(ActivityStatusCard), findsOneWidget);
  });

  // ----------------------------------------------------
  // TEST 4: APERTURA DEL MODAL
  // ----------------------------------------------------
  testWidgets('4. Debe abrir el modal de creación al presionar el FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(CreateActivityModal), findsOneWidget);
  });
}