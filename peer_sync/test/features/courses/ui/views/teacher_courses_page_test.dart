import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// --- Ajusta estas rutas según tu proyecto ---
import 'package:peer_sync/features/course/ui/views/teacher_courses_page.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';

// (Descomenta tus modelos reales y cambia la palabra 'dynamic' si lo deseas)
import 'package:peer_sync/features/course/domain/models/course.dart';
import 'package:peer_sync/features/category/domain/models/category.dart';

// 1. MOCKS DE LOS CONTROLADORES
class MockCourseController extends GetxController with Mock implements CourseController {}
class MockCategoryController extends GetxController with Mock implements CategoryController {}
class MockEvaluationController extends GetxController with Mock implements EvaluationController {}
class MockNotificationController extends GetxController with Mock implements NotificationController {}

class MockCourse extends Mock implements Course {} 
class MockCategory extends Mock implements Category {}

void main() {
  late MockCourseController mockCourseController;
  late MockCategoryController mockCategoryController;
  late MockEvaluationController mockEvaluationController;
  late MockNotificationController mockNotificationController;

  setUp(() {
    mockCourseController = MockCourseController();
    mockCategoryController = MockCategoryController();
    mockEvaluationController = MockEvaluationController();
    mockNotificationController = MockNotificationController();

    // 1. Course Controller
    when(() => mockCourseController.isLoading).thenReturn(false.obs);
    when(() => mockCourseController.courses).thenReturn(<Course>[].obs);
    // En la vista de profesor podría llamarse loadCourses o loadCoursesByUser, mockeamos por si acaso
    when(() => mockCourseController.loadCourses()).thenAnswer((_) async {});

    // 2. Category Controller
    when(() => mockCategoryController.getCategoriesPreview(any())).thenReturn([]);
    when(() => mockCategoryController.getCategoryCountText(any())).thenReturn('2 Categorías');

    // 3. Evaluation Controller
    when(() => mockEvaluationController.getActiveActivitySubtitle(any())).thenReturn('1 Actividad para calificar');

    // 4. Notification Controller (El truco del .obs para evitar el error de GetX)
    final dummyUnread = 5.obs; 
    when(() => mockNotificationController.unreadCount).thenAnswer((_) => dummyUnread.value);

    // Inyectamos todo en GetX
    Get.put<CourseController>(mockCourseController);
    Get.put<CategoryController>(mockCategoryController);
    Get.put<EvaluationController>(mockEvaluationController);
    Get.put<NotificationController>(mockNotificationController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createWidgetUnderTest() {
    return const GetMaterialApp(
      home: TeacherCoursesPage(),
    );
  }

  // ==========================================
  // CASOS DE PRUEBA
  // ==========================================

  testWidgets('1. Debe mostrar el estado de carga (CircularProgressIndicator) al iniciar', (WidgetTester tester) async {
    // Simulamos carga
    when(() => mockCourseController.isLoading).thenReturn(true.obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); 

    // Verificamos que aparece el loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('2. Debe mostrar el Empty State cuando el profesor no tiene cursos', (WidgetTester tester) async {
    // Simulamos carga terminada y lista vacía
    when(() => mockCourseController.isLoading).thenReturn(false.obs);
    when(() => mockCourseController.courses).thenReturn(<Course>[].obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verificamos los textos exactos del código del profesor
    expect(find.text('No has creado ningún curso'), findsOneWidget);
    expect(find.text('Cursos'), findsWidgets); // El título de la vista
  });

  testWidgets('3. Debe renderizar la tarjeta del curso y su proyecto previo', (WidgetTester tester) async {
    // Creamos los datos falsos
    final mockCourse = MockCourse();
    when(() => mockCourse.id).thenReturn('course_prof_1');
    when(() => mockCourse.name).thenReturn('Arquitectura de Software');

    final mockCategory = MockCategory();
    when(() => mockCategory.id).thenReturn('cat_prof_1');
    when(() => mockCategory.name).thenReturn('Entrega Final');

    // Inyectamos los datos falsos
    when(() => mockCourseController.isLoading).thenReturn(false.obs);
    when(() => mockCourseController.courses).thenReturn(<Course>[mockCourse].obs);
    when(() => mockCategoryController.getCategoriesPreview('course_prof_1')).thenReturn([mockCategory]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verificamos que el curso y la categoría se renderizan
    expect(find.text('Arquitectura de Software'), findsOneWidget);
    expect(find.text('Entrega Final'), findsWidgets);
    expect(find.text('2 Categorías'), findsWidgets);
    expect(find.text('1 Actividad para calificar'), findsWidgets);

    // Verificamos que esté el botón flotante (+) para crear un curso nuevo
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}