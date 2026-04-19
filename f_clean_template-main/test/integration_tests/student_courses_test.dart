import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔥 IMPORTACIONES DE MODELOS
import 'package:peer_sync/features/auth/domain/models/auth_user.dart';
import 'package:peer_sync/features/notifications/domain/models/app_notification.dart';

// 🔥 IMPORTACIONES DE REPOSITORIOS E INTERFACES
import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:peer_sync/features/course/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/category/data/repositories/category_repository_impl.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';
import 'package:peer_sync/features/notifications/domain/repositories/i_notification_repository.dart';

// 🔥 IMPORTACIONES DE CONTROLLERS Y SERVICES
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/data/datasources/remote/course_remote_source_service.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/data/datasources/remote/category_remote_source_service.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';

// 🔥 UI
import 'package:peer_sync/features/course/ui/views/student_courses_page.dart';

// =======================================================
// ✅ FAKES CORREGIDOS
// =======================================================

class FakeAuthRepo implements IAuthRepository {
  @override Future<T> safeRequest<T>(Future<T> Function() request) async => await request();
  @override Future<String?> getCurrentUserEmail() async => "test@uninorte.edu.co";
  @override Future<AuthUser?> getSavedUser() async => AuthUser(tokenA: "t", tokenR: "r", email: "test@uninorte.edu.co", role: "student", name: "User Test");
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthController extends GetxController implements AuthController {
  @override AuthUser? get user => AuthUser(tokenA: "t", tokenR: "r", email: "test@uninorte.edu.co", role: "student", name: "User Test");
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNotificationRepo implements INotificationRepository {
  // Se usa el tipo AppNotification para respetar la interfaz
  @override 
  Future<List<AppNotification>> getUserNotifications(String email) async => [];
  
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEvaluationRepo implements IEvaluationRepository {
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// =======================================================
// ✅ MAIN TEST
// =======================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('StudentCoursesPage Integration Test', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'email': 'test@uninorte.edu.co',
        'tokenA': 'valid_token'
      });
      await Get.deleteAll(force: true);
      Get.testMode = true;
    });

    testWidgets('Debe cargar cursos y validar UI', (tester) async {
      final mockHttpClient = MockClient((request) async {
        final url = request.url.toString();

        if (url.contains('tableName=Users')) {
          return http.Response('[{"user_id": "123", "email": "test@uninorte.edu.co"}]', 200);
        }
        if (url.contains('tableName=CourseMember')) {
          return http.Response('[{"course_id": 101}]', 200);
        }
        if (url.contains('tableName=Course')) {
          return http.Response('''{
            "records": [
              {
                "course_id": 101,
                "course_name": "Arquitectura de SW",
                "code": 12345
              }
            ]
          }''', 200);
        }
        return http.Response('[]', 200);
      });

      // --- INYECCIÓN DE DEPENDENCIAS ---
      
      final authRepo = FakeAuthRepo();
      Get.put<AuthController>(FakeAuthController());
      
      // 1. Course
      final courseSource = CourseRemoteSourceService(client: mockHttpClient);
      final courseRepo = CourseRepositoryImpl(courseSource, authRepo);
      final courseController = Get.put(CourseController(repository: courseRepo));

      // 2. Category (CORREGIDO: Se pasa el token requerido)
      final categorySource = CategoryRemoteSourceService(
        token: 'fake_token_for_test', 
        client: mockHttpClient
      );
      final categoryRepo = CategoryRepositoryImpl(categorySource, authRepo);
      Get.put(CategoryController(repository: categoryRepo));

      // 3. Evaluation y Notification
      Get.put(EvaluationController(FakeEvaluationRepo()));
      Get.put(NotificationController(FakeNotificationRepo()));

      // --- EJECUCIÓN ---
      
      // Forzar carga de datos
      await courseController.loadCoursesByUser();
      
      // Renderizar página
      await tester.pumpWidget(const GetMaterialApp(
        home: StudentCoursesPage(),
      ));

      // Tiempo para que GetX actualice los Obx
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // --- VERIFICACIÓN ---
      
      debugPrint("📊 Cursos finales en Controller: ${courseController.courses.length}");

      expect(courseController.courses.isNotEmpty, true);
      expect(find.text("Arquitectura de SW"), findsOneWidget);
    });
  });
}