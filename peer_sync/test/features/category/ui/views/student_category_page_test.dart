import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Importaciones de tu proyecto
import 'package:peer_sync/features/category/ui/views/student_category_page.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/category/domain/models/category.dart';
import 'package:peer_sync/features/category/ui/widgets/category_card.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';

// --- FAKES ---
class FakeBuildContext extends Fake implements BuildContext {}

class FakeActivity extends Fake implements Activity {}

// --- MOCKS ---
class MockCategoryController extends GetxController
    with Mock
    implements CategoryController {}

class MockEvaluationController extends GetxController
    with Mock
    implements EvaluationController {}

class MockEvaluationAnalyticsController extends GetxController
    with Mock
    implements EvaluationAnalyticsController {}

void main() {
  late MockCategoryController mockCategoryController;
  late MockEvaluationController mockEvaluationController;
  late MockEvaluationAnalyticsController mockAnalyticsController;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeActivity());
  });

  setUp(() {
    mockCategoryController = MockCategoryController();
    mockEvaluationController = MockEvaluationController();
    mockAnalyticsController = MockEvaluationAnalyticsController();

    // 1. Configurar Mocks para CategoryController
    when(() => mockCategoryController.isLoading).thenReturn(false.obs);
    when(() => mockCategoryController.categories).thenReturn(<Category>[].obs);
    when(
      () => mockCategoryController.loadCategoriesByStudent(any()),
    ).thenAnswer((_) async {});

    // 2. Configurar Mocks para EvaluationController
    when(
      () => mockEvaluationController.getActiveActivitySubtitle(any()),
    ).thenReturn("Sin actividades pendientes");

    // CORRECCIÓN CRÍTICA PARA TEST 4:
    when(
      () => mockEvaluationController.isLoadingActivities,
    ).thenReturn(false.obs);
    when(
      () => mockEvaluationController.activities,
    ).thenReturn(<Activity>[].obs);

    // NUEVO: Debemos mockear sortedActivities porque la vista lo usa para el ListView
    when(
      () => mockEvaluationController.sortedActivities,
    ).thenReturn(<Activity>[]);

    when(
      () => mockEvaluationController.loadActivities(any()),
    ).thenAnswer((_) async {});

    when(
      () => mockAnalyticsController.teacherCategoryCriteriaChart,
    ).thenReturn(<ChartPoint>[].obs);

    when(
      () => mockAnalyticsController.isLoadingTeacherCategoryAnalytics,
    ).thenReturn(false.obs);

    when(
      () => mockAnalyticsController.loadTeacherCategoryAnalytics(any()),
    ).thenAnswer((_) async {});

    // Inyectar controladores
    Get.put<CategoryController>(mockCategoryController);
    Get.put<EvaluationController>(mockEvaluationController);
    Get.put<EvaluationAnalyticsController>(mockAnalyticsController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    '1. Debe llamar a loadCategoriesByStudent al iniciar y mostrar título',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: CourseDetailPage(
            courseId: 'c1',
            courseTitle: 'Ingeniería de Software',
          ),
        ),
      );
      expect(find.text('Ingeniería de Software'), findsOneWidget);
      verify(
        () => mockCategoryController.loadCategoriesByStudent('c1'),
      ).called(1);
    },
  );

  testWidgets(
    '2. Debe mostrar CircularProgressIndicator cuando isLoading es true',
    (WidgetTester tester) async {
      when(() => mockCategoryController.isLoading).thenReturn(true.obs);
      await tester.pumpWidget(
        const GetMaterialApp(
          home: CourseDetailPage(courseId: 'c1', courseTitle: 'Test'),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    '3. Debe renderizar las tarjetas de categoría con sus subtítulos',
    (WidgetTester tester) async {
      final cat = Category(
        id: 'cat1',
        name: 'Grupo de Desarrollo',
        courseId: 'c1',
      );
      when(
        () => mockCategoryController.categories,
      ).thenReturn(<Category>[cat].obs);
      when(
        () => mockEvaluationController.getActiveActivitySubtitle('cat1'),
      ).thenReturn("2 actividades activas");

      await tester.pumpWidget(
        const GetMaterialApp(
          home: CourseDetailPage(courseId: 'c1', courseTitle: 'Test'),
        ),
      );
      await tester.pump();

      expect(find.byType(ProjectCategoryCard), findsOneWidget);
      expect(find.text('Grupo de Desarrollo'), findsOneWidget);
      expect(find.text('2 actividades activas'), findsOneWidget);
    },
  );

  testWidgets(
    '4. Debe navegar a StudentActivitiesPage al tocar una categoría',
    (WidgetTester tester) async {
      final cat = Category(id: 'cat1', name: 'Grupo A', courseId: 'c1');
      when(
        () => mockCategoryController.categories,
      ).thenReturn(<Category>[cat].obs);
      await tester.pumpWidget(
        GetMaterialApp(
          home: CourseDetailPage(courseId: 'c1', courseTitle: 'Test'),
        ),
      );
      await tester.pump();
      final cardFinder = find.byType(ProjectCategoryCard);
      expect(cardFinder, findsOneWidget);

      await tester.tap(cardFinder);
      await tester.pumpAndSettle();
      verify(() => mockEvaluationController.loadActivities('cat1')).called(1);
      expect(find.byType(StudentActivitiesPage), findsOneWidget);
    },
  );
}
