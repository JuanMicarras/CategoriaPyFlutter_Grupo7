import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 🔥 TUS IMPORTS REALES (Ajusta las rutas si varían en tu proyecto)
import 'package:peer_sync/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:peer_sync/features/auth/data/datasources/remote/i_authentication_source.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/course/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/data/datasources/remote/course_remote_source_service.dart';
import 'package:peer_sync/features/category/data/repositories/category_repository_impl.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/data/datasources/remote/category_remote_source_service.dart';
import 'package:peer_sync/features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/data/datasources/remote/evaluation_remote_source.dart';
import 'package:peer_sync/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/student/ui/views/student_home_page.dart';
import 'package:peer_sync/features/notifications/domain/models/app_notification.dart';

// ✅ JWT VÁLIDO (Base64 real para evitar RangeError en split('.'))
const String validFakeJwt =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3ODA2NjI0MDB9.signature";

// ✅ MOCKS DE INTERFACES
class MockAuthSource implements IAuthenticationSource {
  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

class FakeNotificationRepo implements INotificationRepository {
  @override
  Future<List<AppNotification>> getUserNotifications(String email) async => [];
  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('StudentHomePage Integration Test - FINAL', () {
    setUp(() async {
      // 1. Seteamos las llaves EXACTAS que pide tu AuthRepositoryImpl
      SharedPreferences.setMockInitialValues({
        'tokenA': validFakeJwt,
        'tokenR': validFakeJwt,
        'email': 'test@uninorte.edu.co',
        'name': 'User Test',
        'role': 'student',
      });
      await Get.deleteAll(force: true);
    });

    testWidgets('Debe cargar el contenido global (Cursos y Actividades)', (
      tester,
    ) async {
      // 2. Mock de Cliente HTTP para las respuestas de la API
      final mockHttpClient = MockClient((request) async {
        final headers = {'content-type': 'application/json; charset=utf-8'};

        if (request.url.toString().contains('course')) {
          // Devuelve un curso con el nombre "Arquitectura"
          return http.Response(
            jsonEncode([
              {'id': '101', 'name': 'Arquitectura', 'code': 12345},
            ]),
            200,
            headers: headers,
          );
        }
        return http.Response('[]', 200, headers: headers);
      });

      // 3. Inicialización controlada de dependencias
      final authRepo = AuthRepositoryImpl(MockAuthSource());
      final authCtrl = Get.put(
        AuthController(repository: authRepo),
        permanent: true,
      );

      // Esperamos a que AuthController lea SharedPreferences
      await tester.runAsync(() async {
        authCtrl.onInit();
      });
      await tester.pump();

      final courseRepo = CourseRepositoryImpl(
        CourseRemoteSourceService(client: mockHttpClient),
        authRepo,
      );
      final courseCtrl = Get.put(CourseController(repository: courseRepo));

      // Inyectar el resto para que StudentHomePage no explote
      Get.put(
        CategoryController(
          repository: CategoryRepositoryImpl(
            CategoryRemoteSourceService(
              token: validFakeJwt,
              client: mockHttpClient,
            ),
            authRepo,
          ),
        ),
      );
      Get.put(
        EvaluationController(
          EvaluationRepositoryImpl(
            EvaluationRemoteSource(client: mockHttpClient),
          ),
        ),
      );
      Get.put(NotificationController(FakeNotificationRepo()));

      // 4. Cargar la UI
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: StudentHomePage())),
      );

      // 5. Simular paso del tiempo para peticiones asíncronas
      // Tu CourseController llama a loadCourses, le damos tiempo:
      await tester.pump(const Duration(seconds: 1));

      // Forzamos un ciclo extra para que los Obx se enteren del cambio de data
      await tester.pumpAndSettle();

      // 6. VERIFICACIÓN FINAL
      // Buscamos el texto del curso que inyectamos en el MockClient
      expect(find.textContaining("Arquitectura"), findsOneWidget);
      print("✅ TEST PASADO: Curso 'Arquitectura' encontrado en pantalla.");
    });
  });
}
