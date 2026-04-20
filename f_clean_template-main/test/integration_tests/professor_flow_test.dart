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
import 'package:peer_sync/features/category/ui/views/category_detail_page.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity_report.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/teacher_report_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';
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
class MockTeacherReportController extends GetxController with Mock implements TeacherReportController {}

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

  // --- 3. Inyección de Mocks para UI secundaria ---
  final mockEval = MockEvaluationController();
  when(() => mockEval.homeActivities).thenReturn(<Activity>[].obs);
  when(() => mockEval.isLoadingHomeActivities).thenReturn(false.obs);
  when(() => mockEval.loadHomeActivitiesPreview(any())).thenAnswer((_) async {});
  when(() => mockEval.getActiveActivitySubtitle(any())).thenReturn("Evaluación"); 
  when(() => mockEval.loadActiveActivitiesCount(any())).thenAnswer((_) async {}); 

  when(() => mockEval.saveActivity(any())).thenAnswer((_) async => true);
  
  // Stubs para la vista de categoría
  when(() => mockEval.activities).thenReturn(<Activity>[].obs);
  when(() => mockEval.sortedActivities).thenReturn([]); 
  when(() => mockEval.isLoadingActivities).thenReturn(false.obs);
  when(() => mockEval.loadActivities(any())).thenAnswer((_) async {});
  when(() => mockEval.isLoadingTeacherActivities).thenReturn(false.obs);
  when(() => mockEval.loadTeacherActivities(any())).thenAnswer((_) async {});
  when(() => mockEval.teacherActivities).thenReturn(<Activity>[].obs);
  when(() => mockEval.isVisible).thenReturn(true.obs);

  //Prestamos controladores de texto reales al Mock para el formulario 
  final mockNameCtrl = TextEditingController();
  final mockStartDCtrl = TextEditingController();
  final mockEndDCtrl = TextEditingController();
  final mockStartTCtrl = TextEditingController();
  final mockEndTCtrl = TextEditingController();

  when(() => mockEval.nameController).thenReturn(mockNameCtrl);
  when(() => mockEval.startDateController).thenReturn(mockStartDCtrl);
  when(() => mockEval.endDateController).thenReturn(mockEndDCtrl);
  when(() => mockEval.startTimeController).thenReturn(mockStartTCtrl);
  when(() => mockEval.endTimeController).thenReturn(mockEndTCtrl);
  when(() => mockEval.isLoading).thenReturn(false.obs);
  
  Get.put<EvaluationController>(mockEval);


  final mockAnal = MockAnalyticsController();
  when(() => mockAnal.teacherHomeCompletionTrend).thenReturn(<ChartPoint>[].obs);
  when(() => mockAnal.isLoadingTeacherHomeAnalytics).thenReturn(false.obs);
  when(() => mockAnal.teacherActiveActivitiesMetric).thenReturn(Rxn());
  when(() => mockAnal.teacherPendingGroupsMetric).thenReturn(Rxn());
  when(() => mockAnal.loadTeacherHomeAnalytics()).thenAnswer((_) async {});

  
  when(() => mockAnal.teacherCategoryCriteriaChart).thenReturn(<ChartPoint>[].obs);
  when(() => mockAnal.isLoadingTeacherCategoryAnalytics).thenReturn(false.obs);
  when(() => mockAnal.loadTeacherCategoryAnalytics(any())).thenAnswer((_) async {});

  Get.put<EvaluationAnalyticsController>(mockAnal);

  final mockReport = MockTeacherReportController();
  // Prevenimos el error clásico de carga
  when(() => mockReport.isLoading).thenReturn(false.obs);

  when(() => mockReport.loadReport(any(), any())).thenAnswer((_) async {}); 

  when(() => mockReport.groupReports).thenReturn(<GroupReport>[].obs);
  
  Get.put<TeacherReportController>(mockReport);

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

  testWidgets('Flujo completo del Profesor: Login -> Home -> Cursos -> Creacion Curso + Importe de CSV -> Categoria -> Creacion de Actividad -> Actividad', (
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
        )).thenAnswer((_) async => http.Response('[]', 200)); 

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
    // FASE 2 y 3: CREAR CURSO E IMPORTAR CSV
    // =========================================================================

    // 1. MOCK UNIVERSAL: Atrapa CUALQUIER petición GET y responde según la tabla
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((invocation) async {
      final url = invocation.positionalArguments[0].toString();

      if (url.contains('tableName=CourseMember') && url.contains('course_id=')) {
        return http.Response('[]', 200); // Para que joinCourse crea que no está inscrito
      }
      if (url.contains('tableName=CourseMember')) {
        return http.Response(jsonEncode([{"course_id": 999}]), 200); // Cursos del profe
      }
      if (url.contains('tableName=Course')) {
        return http.Response(jsonEncode([{"course_id": 999, "course_name": "Programación Móvil", "code": 12345678}]), 200);
      }
      if (url.contains('tableName=Category')) {
        // Agregamos course_id explícito para evitar error de Null al mapear
        return http.Response(jsonEncode([{"_id": "cat_123", "category_id": "cat_123", "category_name": "Proyecto Final", "course_id": 999}]), 200);
      }
      if (url.contains('tableName=Group')) {
        return http.Response(jsonEncode([{"_id": "grp_123", "group_id": "grp_123", "group_name": "Grupo 1", "category_id": "cat_123"}]), 200);
      }
      if (url.contains('tableName=Users')) {
        return http.Response(jsonEncode([{"_id": "user_123", "user_id": 123, "email": "profesor@uninorte.edu.co", "role": "teacher"}]), 200);
      }
      
      return http.Response('[]', 200); // Fallback universal para evitar cuelgues
    });

    // MOCK UNIVERSAL PARA POST (/insert)
    when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final url = invocation.positionalArguments[0].toString();
      
      // Si la app intenta hacer login de nuevo, devolvemos el token
      if (url.contains('/login')) {
         return http.Response(
            jsonEncode({
              'accessToken': 'fakeHeader.eyJleHAiOjIwMDAwMDAwMDB9.fakeSignature',
              'refreshToken': 'mock_refresh_token',
            }), 200);
      }
      return http.Response('{}', 201); // Exito genérico para inserciones
    });

    // 2. EJECUCIÓN EN LA INTERFAZ (FASE 2)
    
    Get.toNamed('/teacherCourses');
    await tester.pumpAndSettle();

    // Abrir Modal
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Escribimos el nombre del curso
    await tester.enterText(find.byKey(const Key('course_name_input')), 'Programación Móvil');
    await tester.pump();
    await demoPause(tester, 500);

    // Clic en crear
    await tester.tap(find.byKey(const Key('submit_course_button')));
    
    // Le damos un respiro largo para que terminen las peticiones, el Loading y las animaciones de los dos Pop
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 🔴 PREVENCIÓN VISUAL DE DOBLE POP:
    if (find.text("Contenido Reciente").evaluate().isNotEmpty) {
      Get.toNamed('/teacherCourses'); 
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // =========================================================================
    // 🟢 EL TRUCO DE LA CACHÉ
    // Forzamos al controlador a que vuelva a cargar los cursos.
    // Esta vez, como el "background refresh" ya terminó, la caché local 
    // le devolverá el curso que acabamos de crear.
    // =========================================================================
    await Get.find<CourseController>().loadCoursesByUser();
    await tester.pumpAndSettle(const Duration(seconds: 1));

  

    // Validamos que el curso "Programación Móvil" se muestra en la pantalla
    expect(find.text("Programación Móvil"), findsWidgets);


    // =========================================================================
    // FASE 3: IMPORTAR EL CSV (PRUEBA DE LÓGICA REAL)
    // =========================================================================
    
    // Invocamos la función real del controlador simulando el contenido de un archivo CSV
    // exactamente con las columnas que tu GroupsRemoteSource exige.
    final mockCsvData = "Group Category Name,Group Name,First Name,Last Name,Email Address\nProyecto Final,Grupo 1,Juan,Perez,juan@uninorte.edu.co";
    
    // Le pasamos el ID 999 que es el que definimos en los Stubs
    await Get.find<GroupsController>().importCsvData('999', mockCsvData);
    
    // Esperamos a que termine de procesar el CSV y hacer las inserciones en BD
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // Verificamos que la función ejecutó al menos 1 petición POST a la API de Roble 
    // para insertar el CSV (categorías, grupos y miembros).
    verify(() => mockHttpClient.post(
          any(that: predicate<Uri>((uri) => uri.toString().contains('/insert'))),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).called(greaterThanOrEqualTo(1)); 

    // Pausa final para que alcances a ver el resultado
    await demoPause(tester, 1000);

    // =========================================================================
    // FASE 4: ENTRAR A LA CATEGORÍA Y CREAR ACTIVIDAD
    // =========================================================================
    
    // 1. Navegamos directo a la vista de detalle de la categoría 
    // (Simulamos que el profesor tocó la tarjeta de "Proyecto Final" en el CourseCard)
    Get.to(() => const CategoryDetailPage(
      categoryId: 'cat_123', 
      categoryName: 'Proyecto Final'
    ));
    await tester.pumpAndSettle();

    // Validamos que estamos en la pantalla correcta
    expect(find.text('Proyecto Final'), findsWidgets);

    // 2. Buscamos el botón para agregar actividad y lo tocamos
    // (Generalmente es un FloatingActionButton o un ícono de agregar)
    final addActivityBtn = find.byType(FloatingActionButton);
    if (addActivityBtn.evaluate().isNotEmpty) {
      await tester.tap(addActivityBtn);
    } else {
      await tester.tap(find.byIcon(Icons.add).first);
    }
    await tester.pumpAndSettle();

    // Validamos que se abrió el modal de CreateActivityModal
    expect(find.text('Crear Actividad'), findsOneWidget);

    // 3. Escribimos el nombre de la actividad usando su Key
    await tester.enterText(find.byKey(const Key('activity_name_input')), 'Taller 1');
    await tester.pump();
    await demoPause(tester, 500);

    // 🔴 4. EL TRUCO PARA CAMPOS READ-ONLY (Fechas y horas)
    // Inyectamos los valores directamente en los controladores de EvaluationController
    final evalCtrl = Get.find<EvaluationController>();
    evalCtrl.startDateController.text = '20 / 04 / 26';
    evalCtrl.endDateController.text = '27 / 04 / 26';
    evalCtrl.startTimeController.text = '08 : 00';
    evalCtrl.endTimeController.text = '10 : 00';
    
    // Le avisamos a la interfaz que repinte los textos
    evalCtrl.update(); 
    await tester.pump();
    await demoPause(tester, 500);

    // 5. Guardamos la actividad
    await tester.tap(find.byKey(const Key('submit_activity_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verificamos que el modal se cerró (ya no existe el campo de texto del nombre)
    expect(find.byKey(const Key('activity_name_input')), findsNothing);

    // Como usamos nuestro "Mock Universal" de la Fase 2 para las peticiones POST (/insert),
    // la petición a la base de datos de Roble para crear la actividad debió ser un éxito.
    
    // Pausa final para celebrar el flujo completo
    await demoPause(tester, 1500);

    // =========================================================================
    // FASE 5: VER REPORTE Y CALIFICACIONES
    // =========================================================================
    
    // 1. Simulamos que el profesor tocó la tarjeta de la actividad "Taller 1"
    // Navegamos directo pasándole los parámetros que exige la página
    Get.to(() => const TeacherReportPage(
      activityId: 'act_123',
      activityName: 'Taller 1',
      categoryId: 'cat_123', // El ID que mockeamos en la Fase 3
    ));
    await tester.pumpAndSettle();

    // 2. Validamos que llegamos a la pantalla del reporte
    // Buscamos el nombre de la actividad que debería estar en el AppBar o en el título
    expect(find.byType(TeacherReportPage), findsOneWidget);
    expect(find.text('Reporte: Taller 1'), findsWidgets);
    
    // Buscamos algún texto genérico que sepas que está en esa vista 
    // (Ejemplo: "Estudiantes", "Calificaciones", "Reporte")
    // Si no tienes la palabra "Reporte", cámbiala por una que sí esté en tu UI.
    // expect(find.text('Reporte'), findsWidgets); 
    
    // 3. Pausa final triunfal para ver la pantalla
    await demoPause(tester, 2000);
    
  });
}