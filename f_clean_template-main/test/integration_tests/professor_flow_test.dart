import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:peer_sync/features/auth/ui/views/login_page.dart';
import 'package:peer_sync/features/category/data/datasources/remote/category_remote_source_service.dart';
import 'package:peer_sync/features/category/data/repositories/category_repository_impl.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
import 'package:peer_sync/features/groups/data/datasources/remote/groups_remote_source.dart';
import 'package:peer_sync/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';
import 'package:peer_sync/features/teacher/ui/views/teacher_home_page.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:peer_sync/features/auth/data/datasources/remote/authentication_source_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/course/data/datasources/remote/course_remote_source_service.dart';
import 'package:peer_sync/features/course/ui/views/teacher_courses_page.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';


class MockCategoryController extends GetxController with Mock implements CategoryController {}
class MockEvaluationController extends GetxController with Mock implements EvaluationController {}
class MockAnalyticsController extends GetxController with Mock implements EvaluationAnalyticsController {}
class MockNotifController extends GetxController with Mock implements NotificationController {}

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

late MockHttpClient mockHttpClient;

Future<Widget> createPeerSyncApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  Get.reset();
  
  // Limpiamos la caché de pruebas anteriores
  SharedPreferences.setMockInitialValues({}); 

  mockHttpClient = MockHttpClient();

  // --- 1. Inyección de Auth ---
  final authSource = AuthenticationSourceService(client: mockHttpClient);
  final authRepo = AuthRepositoryImpl(authSource); 
  Get.put<AuthController>(AuthController(repository: authRepo));

  // --- 2. Inyección de Cursos ---
  final courseSource = CourseRemoteSourceService(client: mockHttpClient);
  final courseRepo = CourseRepositoryImpl(courseSource, authRepo);
  Get.put<CourseController>(CourseController(repository: courseRepo));

  final mockEval = MockEvaluationController();
  when(() => mockEval.homeActivities).thenReturn(<Activity>[].obs);
  when(() => mockEval.isLoadingHomeActivities).thenReturn(false.obs);
  when(() => mockEval.loadHomeActivitiesPreview(any())).thenAnswer((_) async {});
  when(() => mockEval.getActiveActivitySubtitle(any())).thenReturn("Evaluación"); 
  Get.put<EvaluationController>(mockEval);

  final mockAnal = MockAnalyticsController();
  when(() => mockAnal.teacherHomeCompletionTrend).thenReturn(<ChartPoint>[].obs);
  when(() => mockAnal.isLoadingTeacherHomeAnalytics).thenReturn(false.obs);
  when(() => mockAnal.teacherActiveActivitiesMetric).thenReturn(Rxn());
  when(() => mockAnal.teacherPendingGroupsMetric).thenReturn(Rxn());
  when(() => mockAnal.loadTeacherHomeAnalytics()).thenAnswer((_) async {});
  Get.put<EvaluationAnalyticsController>(mockAnal);

  final mockNotif = MockNotifController();
  final dummyObs = 0.obs; 
  when(() => mockNotif.unreadCount).thenAnswer((_) => dummyObs.value);
  Get.put<NotificationController>(mockNotif);

  // --- 4. INYECCIÓN DE CONTROLADORES REALES (CSV Y CATEGORÍAS) ---
  final fakeToken = 'fakeHeader.eyJleHAiOjIwMDAwMDAwMDB9.fakeSignature';
  
  final categorySource = CategoryRemoteSourceService(token: fakeToken, client: mockHttpClient);
  final categoryRepo = CategoryRepositoryImpl(categorySource, authRepo);
  Get.put<CategoryController>(CategoryController(repository: categoryRepo));

  final groupsSource = GroupsRemoteSource(client: mockHttpClient);
  final groupsRepo = GroupsRepositoryImpl(groupsSource);
  Get.put<GroupsController>(GroupsController(groupsRepo));

  // RETORNO DE LA APP
  return GetMaterialApp(
    initialRoute: '/login',
    getPages: [
      GetPage(name: '/login', page: () => LoginPage()),
      GetPage(name: '/homeTeacher', page: () => const TeacherHomePage()),
      GetPage(name: '/teacherCourses', page: () => const TeacherCoursesPage()),
    ],
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

setUpAll(() {
    registerFallbackValue(FakeUri());
    
    // TRUCO: Ignorar errores visuales de desbordamiento (RenderFlex) 
    // que solo ocurren porque la pantalla del test es pequeña.
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

  testWidgets('Flujo completo del Profesor: Login -> Home -> Cursos', (
    WidgetTester tester,
  ) async {
    // 1. Montamos la app real
    final appWidget = await createPeerSyncApp();

    // =========================================================================
    // STUBS DE LA API
    // =========================================================================

    // Stub POST /login
    when(
      () => mockHttpClient.post(
        any(that: predicate<Uri>((uri) => uri.toString().contains('/login'))),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode({
          // Le pasamos un Token JWT falso pero estructuralmente válido.
          // La parte del medio (Payload) se decodifica como {"exp": 2000000000}
          'accessToken': 'fakeHeader.eyJleHAiOjIwMDAwMDAwMDB9.fakeSignature',
          'refreshToken': 'mock_refresh_token',
        }),
        200, 
      ),
    );
    // Stub GET para obtener el usuario actual
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => 
            uri.toString().contains('tableName=Users') && 
            uri.toString().contains('email='))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([
            {
              '_id': 'user_123',
              'user_id': 123,
              'email': 'profesor@uninorte.edu.co', // El correo que usamos en el login
              'first_name': 'Profe',
              'last_name': 'Test',
              'role': 'teacher'
            }
          ]),
          200,
        ));

    // Stub GET para CourseMember (Cursos a los que pertenece)
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => uri.toString().contains('tableName=CourseMember'))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response('[]', 200)); // Devuelve lista vacía al inicio

    // Stub GET tabla Users
    when(
      () => mockHttpClient.get(
        any(
          that: predicate<Uri>(
            (uri) =>
                uri.toString().contains('tableName=Users') &&
                uri.toString().contains('email='),
          ),
        ),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode([
          {
            '_id': 'user_123',
            'user_id': 123,
            'email': 'profesor@uninorte.edu.co',
            'first_name': 'Profe',
            'last_name': 'Test',
            'role': 'teacher',
          },
        ]),
        200,
      ),
    );

    // =========================================================================
    // EJECUCIÓN (LA MARIONETA)
    // =========================================================================

    await tester.pumpWidget(appWidget);
    await tester.pumpAndSettle();

    // Validar que estamos en Login
    expect(find.text("Inicia Sesión"), findsWidgets);

    // Buscamos los widgets por sus nuevos KEYS
    final emailField = find.byKey(const Key('login_email_field'));
    final passwordField = find.byKey(const Key('login_password_field'));
    final loginButton = find.byKey(const Key('login_submit_button'));

    // Escribir datos
    await tester.enterText(emailField, 'profesor@uninorte.edu.co');
    await tester.pump();
    await demoPause(tester, 500);

    await tester.enterText(passwordField, 'Profesor123!');
    await tester.pump();
    await demoPause(tester, 500);

    // Clic en Iniciar Sesión
    await tester.tap(loginButton);
    await tester.pump();

    // pumpAndSettle espera a que acaben todas las animaciones (como la navegación a /homeTeacher)
    await tester.pumpAndSettle();

    // Verificar que estamos en la pantalla de Home del profesor
    expect(find.text("Contenido Reciente"), findsOneWidget);

    // Verificar que se llamó a la API de login
    verify(
      () => mockHttpClient.post(
        any(that: predicate<Uri>((uri) => uri.toString().contains('/login'))),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).called(1);

    // =========================================================================
    // FASE 2: NAVEGAR A CURSOS Y CREAR UN CURSO
    // =========================================================================

    // 1. STUBS (MOCKS) PARA LA CREACIÓN DEL CURSO
    
    // Stub para POST general (/insert) (Crea el curso y el CourseMember)
    when(() => mockHttpClient.post(
          any(that: predicate<Uri>((uri) => uri.toString().contains('/insert'))),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer((_) async => http.Response('{}', 201));

    // AQUI ESTABA EL ERROR: Necesitamos que la validación inicial devuelva VACÍO (no inscrito)
    // para que la función joinCourse no lance la excepción y el modal pueda cerrarse.
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => 
            uri.toString().contains('tableName=CourseMember') && uri.toString().contains('course_id='))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

    // Pero cuando GetX pida los cursos del usuario (Home/Lista), ahí SI devolvemos el curso 999.
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => 
            uri.toString().contains('tableName=CourseMember') && 
            uri.toString().contains('user_id=') && 
            !uri.toString().contains('course_id='))), // Para diferenciarlo del de arriba
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{"course_id": 999}]), 200));

    // Datos falsos del curso que acabamos de crear
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => 
            uri.toString().contains('tableName=Course') && 
            (uri.toString().contains('course_id=999') || uri.toString().contains('code=')))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{"course_id": 999, "course_name": "Programación Móvil", "code": 12345678}]), 200));

    // Stubs para la creación de Categorías y Grupos desde el CSV
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => uri.toString().contains('tableName=Category'))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{"_id": "cat_123", "category_name": "Proyecto Final"}]), 200));

    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => uri.toString().contains('tableName=Group'))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{"_id": "grp_123", "group_name": "Grupo 1"}]), 200));

    // Devolvemos vacío en GroupMember para forzar al controlador a que inserte a los estudiantes
    when(() => mockHttpClient.get(
          any(that: predicate<Uri>((uri) => uri.toString().contains('tableName=GroupMember'))),
          headers: any(named: 'headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode([]), 200));

    // 2. EJECUCIÓN EN LA INTERFAZ
    
    // Navegamos a la vista de cursos
    Get.toNamed('/teacherCourses');
    await tester.pumpAndSettle();
    expect(find.text("Cursos"), findsWidgets);

    // Tocamos el FloatingActionButton para abrir el modal (+)
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text("Crear Curso"), findsOneWidget);

    // Escribimos el nombre del curso
    await tester.enterText(find.byKey(const Key('course_name_input')), 'Programación Móvil');
    await tester.pump();
    await demoPause(tester, 500);

    // Tocamos el botón de crear
    await tester.tap(find.byKey(const Key('submit_course_button')));
    await tester.pumpAndSettle();

    // Verificamos que el modal cerró (Ya no hay campos de texto)
    expect(find.byType(TextField), findsNothing); 
    // Verificamos que la tarjeta del curso aparece
    expect(find.text("Programación Móvil"), findsOneWidget); 

    // =========================================================================
    // FASE 3: IMPORTAR EL CSV (PRUEBA DE LÓGICA REAL)
    // =========================================================================
    
    // Creamos un CSV con las columnas exactas que exige tu GroupsRemoteSource
    final mockCsvData = "Group Category Name,Group Name,First Name,Last Name,Email Address\nProyecto Final,Grupo 1,Juan,Perez,juan@uninorte.edu.co\nProyecto Final,Grupo 2,Maria,Gomez,maria@uninorte.edu.co";
    
    // Invocamos la función real
    await Get.find<GroupsController>().importCsvData('999', mockCsvData);
    await tester.pumpAndSettle();
    
    // Validamos en el cliente HTTP que el controlador REAL hizo múltiples peticiones POST
    // (1 para crear el curso + varias para insertar categorías, grupos y miembros del CSV)
    verify(() => mockHttpClient.post(
          any(that: predicate<Uri>((uri) => uri.toString().contains('/insert'))),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).called(greaterThanOrEqualTo(2)); 

    await demoPause(tester, 1000);

  });
}
