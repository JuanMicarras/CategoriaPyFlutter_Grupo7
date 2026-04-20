import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// --- Ajusta estas rutas según tu proyecto ---
import 'package:peer_sync/features/course/ui/views/student_courses_page.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';

// (Descomenta tus modelos reales si lo necesitas y cambia 'dynamic')
import 'package:peer_sync/features/course/domain/models/course.dart';
import 'package:peer_sync/features/category/domain/models/category.dart';

// 1. MOCKS DE TODOS LOS CONTROLADORES
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
    when(() => mockCourseController.loadCoursesByUser()).thenAnswer((_) async {});

    // 2. Category Controller
    when(() => mockCategoryController.getCategoriesPreview(any())).thenReturn([]);
    // 🔴 FIX: Enseñamos al mock qué responder para el subtítulo del progreso del curso
    when(() => mockCategoryController.getCategoryCountText(any())).thenReturn('3 Categorías');

    // 3. Evaluation Controller
    // 🔴 FIX: Enseñamos al mock qué responder para el subtítulo de la actividad
    when(() => mockEvaluationController.getActiveActivitySubtitle(any())).thenReturn('1 Actividad activa');

    // 4. Notification Controller
    final dummyUnread = 0.obs; 
    when(() => mockNotificationController.unreadCount).thenAnswer((_) => dummyUnread.value);

    // Inyectamos a GetX
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
      home: StudentCoursesPage(),
    );
  }

  // ==========================================
  // CASOS DE PRUEBA
  // ==========================================

  testWidgets('1. Debe mostrar estado de carga inicial', (WidgetTester tester) async {
    when(() => mockCourseController.isLoading).thenReturn(true.obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); 

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('2. Debe mostrar el estado vacío (Empty State) cuando no hay cursos', (WidgetTester tester) async {
    when(() => mockCourseController.isLoading).thenReturn(false.obs);
    when(() => mockCourseController.courses).thenReturn(<Course>[].obs);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 🔴 FIX: Verificamos los textos exactos de tu nueva UI
    expect(find.text('No estás inscrito en ningún curso'), findsOneWidget);
    expect(find.text('Cursos'), findsWidgets); // Título en el header
  });

  testWidgets('3. Debe renderizar la lista de cursos y sus proyectos internos', (WidgetTester tester) async {
    // Curso falso
    final mockCourse = MockCourse();
    when(() => mockCourse.id).thenReturn('course_123');
    when(() => mockCourse.name).thenReturn('Flutter Avanzado');

    // Categoría falsa
    final mockCategory = MockCategory();
    when(() => mockCategory.id).thenReturn('cat_1');
    when(() => mockCategory.name).thenReturn('Proyecto Final');

    // Inyectamos el curso
    when(() => mockCourseController.isLoading).thenReturn(false.obs);
    when(() => mockCourseController.courses).thenReturn(<Course>[mockCourse].obs);
    
    // Inyectamos la categoría para cuando la UI consulte getCategoriesPreview
    when(() => mockCategoryController.getCategoriesPreview('course_123')).thenReturn([mockCategory]);

    // Ejecutamos
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verificaciones
    expect(find.text('Flutter Avanzado'), findsOneWidget); // Apareció el curso
    expect(find.text('Proyecto Final'), findsWidgets);     // Apareció la categoría hija
    expect(find.text('3 Categorías'), findsWidgets);       // Apareció el progressText
    
    // Botón flotante para agregar cursos
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}