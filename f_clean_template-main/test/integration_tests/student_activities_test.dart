import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

// IMPORTS PROYECTO
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/data/datasources/remote/evaluation_remote_source.dart';
import 'package:peer_sync/features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

/// 🔥 FAKE AUTH
class FakeAuthController extends GetxController implements AuthController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({
      'tokenA': 'fake-token'
    });
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Debe cargar actividades y navegar a evaluación', (tester) async {

    /// 🔥 MOCK HTTP
    final mockHttpClient = MockClient((request) async {

      /// 🔹 MOCK ACTIVITIES
      if (request.url.toString().contains('/read') &&
          request.url.query.contains('Activity')) {
        return http.Response(
          '''
          {
            "data": [
              {
                "_id": "1",
                "category_id": "cat1",
                "name": "Actividad Test",
                "description": "Desc",
                "start_date": "2024-01-01T00:00:00Z",
                "end_date": "2099-01-01T00:00:00Z",
                "visibility": true
              }
            ]
          }
          ''',
          200,
        );
      }

      return http.Response('{}', 200);
    });

    /// 🔥 DATASOURCE
    final datasource =
        EvaluationRemoteSource(client: mockHttpClient);

    /// 🔥 REPO
    final repository =
        EvaluationRepositoryImpl(datasource);

    /// 🔥 INYECCIÓN
    Get.put<AuthController>(FakeAuthController());
    Get.put<IEvaluationRepository>(repository);
    Get.put(EvaluationController(repository));

    /// 🔥 APP
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: '/activities',
            page: () => StudentActivitiesPage(
              categoryId: "cat1",
              categoryName: "Categoría Test",
            ),
          ),
          GetPage(
            name: '/evaluation',
            page: () => StudentEvaluationPage(
              activityId: "1",
              activityName: "Actividad Test",
              categoryId: "cat1",
              visibility: true,
            ),
          ),
        ],
        initialRoute: '/activities',
      ),
    );

    /// 🔥 ESPERAR CARGA
    await tester.pumpAndSettle();

    /// ✅ VALIDAR QUE APARECE LA ACTIVIDAD
    expect(find.text("Actividad Test"), findsOneWidget);

    /// 🔥 TAP EN LA ACTIVIDAD
    await tester.tap(find.text("Actividad Test"));
    await tester.pumpAndSettle();

    /// ✅ VALIDAR NAVEGACIÓN
    expect(find.byType(StudentEvaluationPage), findsOneWidget);
  });
}
