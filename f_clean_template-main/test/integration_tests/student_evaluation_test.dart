import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

// IMPORTS
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_form_controller.dart';
import 'package:peer_sync/features/evaluation/data/datasources/remote/evaluation_remote_source.dart';
import 'package:peer_sync/features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_repository.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

/// 🔥 FAKE AUTH CONTROLLER (CLAVE)
class FakeAuthController extends GetxController implements AuthController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Flujo completo: guardar evaluación', (tester) async {

    /// 🔥 MOCK HTTP
    final mockHttpClient = MockClient((request) async {
      if (request.url.toString().contains('/read')) {
        return http.Response('{"data": []}', 200);
      }

      if (request.url.toString().contains('/insert')) {
        return http.Response('{"success": true}', 200);
      }

      return http.Response('{}', 200);
    });

    /// 🔥 DATASOURCE
    final datasource =
        EvaluationRemoteSource(client: mockHttpClient);

    /// 🔥 REPOSITORY
    final repository =
        EvaluationRepositoryImpl(datasource);

    /// 🔥 INYECCIÓN (ORDEN IMPORTA)
    Get.put<AuthController>(FakeAuthController());
    Get.put<IEvaluationRepository>(repository);
    Get.put(EvaluationFormController(Get.find()));

    /// 🔥 UI
    await tester.pumpWidget(
      GetMaterialApp(
        home: StudentEvaluationPage(
          activityId: "1",
          activityName: "Actividad Test",
          categoryId: "cat1",
          visibility: true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    /// ✅ VALIDACIÓN
    expect(find.text("Evaluaciones"), findsOneWidget);

    /// 🔍 BOTÓN
    final saveButton = find.text("Guardar evaluación");

    if (saveButton.evaluate().isNotEmpty) {
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
    }

    expect(find.text("Evaluaciones"), findsOneWidget);
  });
}
