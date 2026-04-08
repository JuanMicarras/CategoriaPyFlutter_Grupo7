import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// --- Imports de tu Proyecto ---
import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/auth/domain/models/auth_user.dart'; 

import 'package:peer_sync/features/course/ui/views/student_courses_page.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/domain/repositories/i_course_repository.dart';
import 'package:peer_sync/features/course/data/repositories/course_repository_impl.dart';
import 'package:peer_sync/features/course/data/datasources/remote/i_course_remote_source.dart';

import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/domain/repositories/i_category_repository.dart';

import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';

// Importamos el controlador SOLO para poder heredar de él
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';

// --- FAKES ---

class FakeAuthController extends GetxController implements AuthController {
  @override
  AuthUser? get user => AuthUser(
    tokenA: 'fake', tokenR: 'fake', email: 'test@test.com', role: 'student', name: 'User'
  );
  @override dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

// Fakes de Repositorios
class FakeAuthRepo implements IAuthRepository { @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i); }
class FakeCourseRemote implements ICourseRemoteSource { @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i); }
class FakeCategoryRepo implements ICategoryRepository { @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i); }
class FakeEvalRepo implements IEvaluationRepository { @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i); }

// --- EL CLAVO PARA EL ATAÚD DE LAS NOTIFICACIONES ---
// Heredamos para que Get.find<NotificationController>() lo acepte, 
// pero usamos noSuchMethod para no tener que implementar nada.
class FakeNotificationController extends GetxController implements NotificationController {
  @override
  void onInit() { /* No hacemos nada, así no busca repositorios */ }

  @override dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('Renderizado exitoso de StudentCoursesPage', (WidgetTester tester) async {
    
    // 1. Inyectar Repositorios
    Get.put<IAuthRepository>(FakeAuthRepo());
    Get.put<ICourseRemoteSource>(FakeCourseRemote());
    Get.put<ICourseRepository>(CourseRepositoryImpl(Get.find(), Get.find()));
    Get.put<ICategoryRepository>(FakeCategoryRepo());
    Get.put<IEvaluationRepository>(FakeEvalRepo());

    // 2. Inyectar AuthController
    Get.put<AuthController>(FakeAuthController());

    // 3. Inyectar Controladores Reales
    Get.put(CourseController(repository: Get.find()));
    Get.put(CategoryController(repository: Get.find()));
    Get.put(EvaluationController(Get.find()));

    // 4. Inyectar el Fake de Notificaciones (Para que la vista no explote)
    // Lo inyectamos como el tipo real que la vista espera.
    Get.put<NotificationController>(FakeNotificationController());

    // 5. Cargar Widget
    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentCoursesPage(),
      ),
    );

    // Esperar a que el frame se dibuje
    await tester.pump();

    // 6. VERIFICACIONES
    // Buscamos el texto 'Cursos' en la AppBar
    final appBarTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Cursos'),
    );
    
    expect(appBarTitle, findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}