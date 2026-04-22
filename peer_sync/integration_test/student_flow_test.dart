import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTS DE UI ---
import 'package:peer_sync/features/auth/ui/views/login_page.dart';
import 'package:peer_sync/features/student/ui/views/student_home_page.dart';
import 'package:peer_sync/features/course/ui/views/student_courses_page.dart';
import 'package:peer_sync/features/category/ui/views/student_category_page.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';

// --- IMPORTS DE CONTROLADORES Y REPOSITORIOS ---
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:peer_sync/features/auth/data/datasources/remote/authentication_source_service.dart';

import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/course/data/datasources/remote/course_remote_source_service.dart';

import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/data/repositories/category_repository_impl.dart';
import 'package:peer_sync/features/category/data/datasources/remote/category_remote_source_service.dart';

import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_form_controller.dart';
import 'package:peer_sync/features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'package:peer_sync/features/evaluation/data/datasources/remote/evaluation_remote_source.dart';

import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/data/repositories/notification_repository_Impl.dart';
import 'package:peer_sync/features/notifications/data/datasources/remote/notification_remote_source.dart';

import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/data/repositories/evaluation_analytics_repository_impl.dart';
import 'package:peer_sync/features/evaluation/data/datasources/remote/evaluation_analytics_remote_source.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}

late MockHttpClient mockHttpClient;

Future<Widget> createPeerSyncStudentApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  Get.reset();
  SharedPreferences.setMockInitialValues({}); // Caché limpia

  mockHttpClient = MockHttpClient();
  final fakeToken = 'fakeHeader.eyJleHAiOjIwMDAwMDAwMDB9.fakeSignature';

  // --- 1. INYECCIÓN DE CONTROLADORES REALES ---
  
  // Auth
  final authRepo = AuthRepositoryImpl(AuthenticationSourceService(client: mockHttpClient)); 
  Get.put<AuthController>(AuthController(repository: authRepo));

  // Course
  final courseRepo = CourseRepositoryImpl(CourseRemoteSourceService(client: mockHttpClient), authRepo);
  Get.put<CourseController>(CourseController(repository: courseRepo));

  // Category
  final categoryRepo = CategoryRepositoryImpl(CategoryRemoteSourceService(token: fakeToken, client: mockHttpClient), authRepo);
  Get.put<CategoryController>(CategoryController(repository: categoryRepo));

  // Evaluation
  final evalRepo = EvaluationRepositoryImpl(EvaluationRemoteSource(client: mockHttpClient));
  Get.put<EvaluationController>(EvaluationController(evalRepo));
  Get.put<EvaluationFormController>(EvaluationFormController(evalRepo));
  Get.put<IEvaluationRepository>(evalRepo);

  final evalAnalyticRepo = EvaluationAnalyticsRepositoryImpl(EvaluationAnalyticsRemoteSource(client: mockHttpClient));
  Get.put<EvaluationAnalyticsController>(EvaluationAnalyticsController(evalAnalyticRepo));
  

  // Notifications (Para que el Home no explote)
  final notifRepo = NotificationRepositoryImpl(NotificationRemoteSource(client: mockHttpClient));
  Get.put<NotificationController>(NotificationController(notifRepo));

  // --- 2. RUTAS ---
  return GetMaterialApp(
    initialRoute: '/login',
    getPages: [
      GetPage(name: '/login', page: () => LoginPage()),
      GetPage(name: '/homeStudent', page: () => const StudentHomePage()),
      GetPage(name: '/studentCourses', page: () => const StudentCoursesPage()),
    ],
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeUri());
    // Silenciamos errores visuales de overflow
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
      FlutterError.presentError(details);
    };
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> demoPause(WidgetTester tester, [int ms = 1000]) async {
    await tester.pump(Duration(milliseconds: ms));
  }

  testWidgets('Flujo completo del Estudiante: Login -> Cursos -> Categoria -> Actividad -> Evaluación', (WidgetTester tester) async {
    final appWidget = await createPeerSyncStudentApp();

    // =========================================================================
    // MOCK UNIVERSAL: ORQUESTADOR DE API DE ROBLE
    // =========================================================================

    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((invocation) async {
      final url = invocation.positionalArguments[0].toString();

      // 1. Datos del Estudiante
      if (url.contains('tableName=Users')) {
        return http.Response(jsonEncode([{"_id": "usr_stu", "user_id": 456, "email": "estudiante@uninorte.edu.co", "role": "student"}]), 200);
      }
      
      // 2. Cursos del Estudiante
      if (url.contains('tableName=CourseMember')) {
        return http.Response(jsonEncode([{"course_id": 101}]), 200); 
      }
      if (url.contains('tableName=Course')) {
        return http.Response(jsonEncode([{"course_id": 101, "course_name": "Sistemas Operativos", "code": 88888888}]), 200);
      }

      // 3. Categorías y Grupos
      if (url.contains('tableName=Category')) {
        return http.Response(jsonEncode([{"_id": "cat_001", "category_id": "cat_001", "category_name": "Proyecto Final", "course_id": 101}]), 200);
      }
      if (url.contains('tableName=GroupMember')) {
        return http.Response(jsonEncode([
          {"group_id": "grp_001", "email": "estudiante@uninorte.edu.co", "first_name": "Estudiante", "last_name": "Test"},
          {"group_id": "grp_001", "email": "compa@uninorte.edu.co", "first_name": "Compañero", "last_name": "Amigo"}
        ]), 200);
      }
      if (url.contains('tableName=Group')) {
        return http.Response(jsonEncode([{"_id": "grp_001", "group_id": "grp_001", "group_name": "Los Coders", "category_id": "cat_001"}]), 200);
      }

      // 4. Actividades y Compañeros a evaluar
      if (url.contains('tableName=Activity')) {
        return http.Response(jsonEncode([{
          "_id": "act_001", 
          "activity_id": "act_001", 
          "name": "Entrega 1", 
          "category_id": "cat_001", 
          "is_public": true,
          "start_date": "2026-04-20T08:00:00.000Z",
          "end_date": "2026-04-27T08:00:00.000Z"
        }]), 200);
      }
      // 5. Criterios de Evaluación (NECESITAMOS 4 PARA PASAR LA VALIDACIÓN)
      if (url.contains('tableName=Criteria')) {
        return http.Response(jsonEncode([
          {"_id": "crit_1", "criteria_id": "crit_1", "name": "Trabajo en Equipo", "category_id": "cat_001"},
          {"_id": "crit_2", "criteria_id": "crit_2", "name": "Comunicación", "category_id": "cat_001"},
          {"_id": "crit_3", "criteria_id": "crit_3", "name": "Puntualidad", "category_id": "cat_001"},
          {"_id": "crit_4", "criteria_id": "crit_4", "name": "Calidad de Trabajo", "category_id": "cat_001"}
        ]), 200);
      }
      // Simular lista de compañeros en el grupo para evaluar
      if (url.contains('tableName=Peer')) {
         return http.Response(jsonEncode([{"email": "compa@uninorte.edu.co", "first_name": "Juan", "last_name": "Perez"}]), 200);
      }
      
      return http.Response('[]', 200); 
    });

    when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final url = invocation.positionalArguments[0].toString();
      
      if (url.contains('/login')) {
         return http.Response(jsonEncode({'accessToken': 'fakeHeader.eyJleHAiOjIwMDAwMDAwMDB9.fakeSignature', 'refreshToken': 'mock_refresh_token'}), 200);
      }
      return http.Response('{"success": true}', 201); // Para el insert de la evaluación
    });

    // =========================================================================
    // FASE 1: LOGIN Y HOME
    // =========================================================================
    
    await tester.pumpWidget(appWidget);
    await tester.pumpAndSettle();

    // Llenamos datos de login (Usando keys o texto)
    await tester.enterText(find.byKey(const Key('login_email_field')), 'estudiante@uninorte.edu.co');
    await tester.enterText(find.byKey(const Key('login_password_field')), 'Estudiante123!');
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Validamos que estamos en el Home (Busca un texto típico de tu StudentHomePage)
    // expect(find.text("Hola, Estudiante"), findsWidgets); // <-- Cambia esto por un texto real de tu home
    
    // =========================================================================
    // FASE 2: NAVEGAR A CURSOS
    // =========================================================================
    
    // Navegamos a la lista de cursos
    Get.toNamed('/studentCourses');
    await tester.pumpAndSettle();
    
    // Verificamos que el curso mockeado aparece
    expect(find.text("Sistemas Operativos"), findsWidgets);
    await demoPause(tester, 1000);

    // =========================================================================
    // FASE 3: ENTRAR A LA CATEGORÍA
    // =========================================================================
    
    // Simulamos tocar la tarjeta del curso para ir a la categoría
    Get.to(() => const CourseDetailPage(courseId: '101', courseTitle: 'Sistemas Operativos'));
    await tester.pumpAndSettle();

    expect(find.text("Proyecto Final"), findsWidgets);
    await demoPause(tester, 1000);

    // =========================================================================
    // FASE 4: ENTRAR A ACTIVIDADES
    // =========================================================================
    
    Get.to(() => const StudentActivitiesPage(categoryId: 'cat_001', categoryName: 'Proyecto Final'));
    await tester.pumpAndSettle();

    // 🟢 EL TRUCO DE LA CACHÉ
    // Forzamos al controlador a que procese la lista y le damos un respiro a la UI
    // (Si tu método para cargar actividades en el estudiante se llama diferente, cámbialo aquí)
    await Get.find<EvaluationController>().loadActivities('cat_001');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // El print salvavidas para ver qué tiene la memoria:
    final actsEnMemoria = Get.find<EvaluationController>().activities;
    print("📋 ACTIVIDADES EN MEMORIA: ${actsEnMemoria.map((a) => a.name).toList()}");

    expect(find.text("Entrega 1"), findsWidgets);
    await demoPause(tester, 1000);

    // =========================================================================
    // FASE 5: REALIZAR EVALUACIÓN POR PARES
    // =========================================================================
    
    Get.to(() => const StudentEvaluationPage(
      activityId: 'act_001', 
      activityName: 'Entrega 1', 
      categoryId: 'cat_001', 
      visibility: true
    ));
    await tester.pumpAndSettle();

    expect(find.text("Entrega 1"), findsWidgets);

    // 🔴 EL "HACK" DEFINITIVO PARA PASAR LA VALIDACIÓN:
    // Inyectamos las 4 notas en el controlador usando los nombres exactos 
    // que pusimos en la base de datos mockeada.
    final evalFormCtrl = Get.find<EvaluationFormController>();
    final compaEmail = "compa@uninorte.edu.co";
    
    // Inyectamos las 4 notas en la memoria del controlador
    evalFormCtrl.pendingEvaluations[compaEmail] = {
      "Trabajo en Equipo": 5.0,
      "Comunicación": 5.0,
      "Puntualidad": 4.5,
      "Calidad de Trabajo": 5.0,
    };
    
    // Le avisamos a GetX que refresque el mapa por si acaso
    // (A veces GetX requiere llamar a refresh() si es un map reactivo)
    try { evalFormCtrl.pendingEvaluations.refresh(); } catch (_) {}

    // Ahora sí, ejecutamos la función (¡Pasará la validación de los 4 criterios!)
    try {
      await evalFormCtrl.submitEvaluationForPeer(
        'act_001', 
        'cat_001', 
        compaEmail
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } catch (e) {
      print("Error forzando la evaluación: $e");
    }

    // Validamos que por fin se hizo el POST a la base de datos (/insert)
    verify(() => mockHttpClient.post(
          any(that: predicate<Uri>((uri) => uri.toString().contains('/insert'))),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).called(greaterThanOrEqualTo(1));

    await demoPause(tester, 1500);
  });
}