import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- IMPORTS DE MODELOS ---
import 'package:peer_sync/features/course/domain/models/course.dart';
import 'package:peer_sync/features/category/domain/models/category.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';

// --- IMPORTS DE CONTROLADORES Y VISTAS ---
import 'package:peer_sync/features/teacher/ui/views/teacher_home_page.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';

// --- FAKES CON TIPADO CORRECTO Y REACTIVIDAD ---

class FakeCourseController extends GetxController implements CourseController {
  @override
  final courses = <Course>[].obs;
  @override
  final isLoading = false.obs;

  @override
  Future<void> loadCoursesByUser() async {}
  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

class FakeCategoryController extends GetxController
    implements CategoryController {
  @override
  String getCategoryCountText(String id) => "3 Categorías";

  @override
  List<Category> getCategoriesPreview(String id) => <Category>[];

  @override
  Future<void> loadCategoriesForCourseCard(String id) async {}
  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

class FakeEvalController extends GetxController
    implements EvaluationController {
  @override
  final homeActivities = <Activity>[].obs;
  @override
  final isLoadingHomeActivities = false.obs;

  @override
  Future<void> loadHomeActivitiesPreview(List<String> ids) async {}
  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

class FakeNotifController extends GetxController
    implements NotificationController {
  // 1. Lo definimos como dinámico o usamos un Getter para burlar la restricción de tipo
  // si el controlador original usa 'int'.
  final _unreadCount = 0.obs;

  @override
  get unreadCount => _unreadCount.value;

  // Creamos un método para que el test pueda cambiar el valor
  void setUnreadCount(int val) => _unreadCount.value = val;

  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() {
    Get.testMode = true;

    // Inyección de dependencias (Fakes)
    Get.put<CourseController>(FakeCourseController());
    Get.put<CategoryController>(FakeCategoryController());
    Get.put<EvaluationController>(FakeEvalController());
    Get.put<NotificationController>(FakeNotifController());
  });

  tearDown(() => Get.reset());

  group('TeacherHomePage Tests', () {
    testWidgets(
      'Muestra mensaje de estado vacío si no hay cursos ni actividades',
      (WidgetTester tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: TeacherHomePage()));

        // Usamos .first por seguridad si hay elementos duplicados en el árbol
        expect(find.text('Home').first, findsOneWidget);
        expect(
          find.text('Actualmente no hay nada para mostrar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Muestra el indicador de carga cuando los controladores están trabajando',
      (WidgetTester tester) async {
        final courseCtrl = Get.find<CourseController>();
        courseCtrl.isLoading.value = true;

        await tester.pumpWidget(const GetMaterialApp(home: TeacherHomePage()));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Actualiza el badge de notificaciones cuando cambia unreadCount',
      (WidgetTester tester) async {
        // 2. Obtenemos el controlador especificando que es nuestro Fake
        final notifCtrl =
            Get.find<NotificationController>() as FakeNotifController;

        await tester.pumpWidget(const GetMaterialApp(home: TeacherHomePage()));

        // 3. Usamos el método que creamos en el fake
        notifCtrl.setUnreadCount(9);

        await tester.pump();

        expect(find.text('9'), findsOneWidget);
        expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      },
    );

    testWidgets('Renderiza el título de la sección de contenido reciente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: TeacherHomePage()));

      expect(find.text('Contenido Reciente'), findsOneWidget);
    });
  });
}
