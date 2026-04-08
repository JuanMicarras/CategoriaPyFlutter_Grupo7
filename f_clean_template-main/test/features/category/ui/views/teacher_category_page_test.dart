import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// --- Ajusta estas rutas según tu proyecto ---
import 'package:peer_sync/features/category/ui/views/teacher_category_page.dart'; 
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
// Importamos tu modelo real
import 'package:peer_sync/features/category/domain/models/category.dart';

// 1. MOCKS DE TODOS LOS CONTROLADORES
class MockCategoryController extends GetxController with Mock implements CategoryController {}
class MockEvaluationController extends GetxController with Mock implements EvaluationController {}
class MockGroupsController extends GetxController with Mock implements GroupsController {}
class MockCourseController extends GetxController with Mock implements CourseController {}
class MockNotificationController extends GetxController with Mock implements NotificationController {}

class MockCategory extends Mock implements Category {}

void main() {
  late MockCategoryController mockCategoryController;
  late MockEvaluationController mockEvaluationController;
  late MockGroupsController mockGroupsController;
  late MockCourseController mockCourseController;
  late MockNotificationController mockNotificationController;

  setUp(() {
    mockCategoryController = MockCategoryController();
    mockEvaluationController = MockEvaluationController();
    mockGroupsController = MockGroupsController();
    mockCourseController = MockCourseController();
    mockNotificationController = MockNotificationController();

    // 1. Category Controller
    when(() => mockCategoryController.isLoading).thenReturn(false.obs);
    when(() => mockCategoryController.categories).thenReturn(<Category>[].obs);
    when(() => mockCategoryController.loadCategories(any())).thenAnswer((_) async {});

    // 2. Evaluation Controller
    when(() => mockEvaluationController.getActiveActivitySubtitle(any())).thenReturn('2 actividades activas');
    when(() => mockEvaluationController.loadActiveActivitiesCount(any())).thenAnswer((_) async {});

    // 3. Course Controller
    // 🔴 EL ARREGLO: Simulamos leer un .obs para calmar a GetX
    final dummyCode = 3141516.obs;
    when(() => mockCourseController.getCodeById(any())).thenAnswer((_) => dummyCode.value);

    // 4. Groups Controller
    when(() => mockGroupsController.isLoading).thenReturn(false.obs);

    // 5. Notification Controller
    // 🔴 EL ARREGLO: Simulamos leer un .obs para calmar a GetX
    final dummyUnread = 3.obs;
    when(() => mockNotificationController.unreadCount).thenAnswer((_) => dummyUnread.value);

    Get.put<CategoryController>(mockCategoryController);
    Get.put<EvaluationController>(mockEvaluationController);
    Get.put<GroupsController>(mockGroupsController);
    Get.put<CourseController>(mockCourseController);
    Get.put<NotificationController>(mockNotificationController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createWidgetUnderTest() {
    return const GetMaterialApp(
      home: TeacherCourseDetailPage(
        courseId: 'course_123',
        courseTitle: 'Ingeniería de Software',
      ),
    );
  }

  // ==========================================
  // CASOS DE PRUEBA
  // ==========================================

  testWidgets('1. Debe mostrar estado de carga inicial si no hay categorías', (WidgetTester tester) async {
    when(() => mockCategoryController.isLoading).thenReturn(true.obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); 

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('2. Debe mostrar el "Empty State" cuando no hay categorías creadas', (WidgetTester tester) async {
    when(() => mockCategoryController.isLoading).thenReturn(false.obs);
    when(() => mockCategoryController.categories).thenReturn(<Category>[].obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); 

    expect(find.text('Ingeniería de Software'), findsWidgets); 
    expect(find.text('3'), findsOneWidget); 
    expect(find.text('Este curso no tiene categorías'), findsOneWidget);
  });

  testWidgets('3. Debe mostrar la lista de categorías si el controlador tiene datos', (WidgetTester tester) async {
    final mockCat = MockCategory();
    when(() => mockCat.id).thenReturn('cat_1');
    when(() => mockCat.name).thenReturn('Entregas Parciales');

    when(() => mockCategoryController.isLoading).thenReturn(false.obs);
    when(() => mockCategoryController.categories).thenReturn(<Category>[mockCat].obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Este curso no tiene categorías'), findsNothing);
    expect(find.text('Entregas Parciales'), findsOneWidget);
    expect(find.text('2 actividades activas'), findsOneWidget);
    verify(() => mockCategoryController.loadCategories('course_123')).called(1);
  });
}