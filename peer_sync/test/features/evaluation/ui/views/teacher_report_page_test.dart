import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Importaciones de tu proyecto
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/teacher_report_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity_report.dart';

// --- MOCK DEL CONTROLADOR ---
class MockTeacherReportController extends GetxController
    with Mock
    implements TeacherReportController {}

void main() {
  late MockTeacherReportController mockController;

  setUp(() {
    mockController = MockTeacherReportController();

    // Estado base reactivo
    when(() => mockController.isLoading).thenReturn(false.obs);
    when(() => mockController.groupReports).thenReturn(<GroupReport>[].obs);

    // Mocks de lógica de presentación (UI Helpers)
    when(() => mockController.formatStudentName(any(), any())).thenAnswer(
      (inv) => '${inv.positionalArguments[0]} ${inv.positionalArguments[1]}',
    );

    when(() => mockController.formatGrade(any())).thenReturn('4.5');

    when(() => mockController.getStudentStatusUI(any())).thenReturn((
      text: 'Completado',
      bgColor: Theme.of(Get.context!).brightness == Brightness.light
          ? Color(0xFFD1B3FF)
          : Color(0xFF3A3260),
      textColor: Theme.of(Get.context!).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    ));

    // Mock de métodos
    when(
      () => mockController.loadReport(any(), any()),
    ).thenAnswer((_) async {});

    // Inyección de dependencia
    Get.put<TeacherReportController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  // ----------------------------------------------------
  // TEST: RENDER Y CARGA
  // ----------------------------------------------------
  testWidgets('Debe mostrar el título y llamar a loadReport', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: TeacherReportPage(
          activityId: 'act_1',
          activityName: 'Evaluación de Pares',
          categoryId: 'cat_1',
        ),
      ),
    );

    expect(find.text('Reporte: Evaluación de Pares'), findsOneWidget);
    verify(() => mockController.loadReport('act_1', 'cat_1')).called(1);
  });

  // ----------------------------------------------------
  // TEST: LISTA CON DATOS (Basado en tu activity_report.dart)
  // ----------------------------------------------------
  testWidgets('Debe mostrar la información del grupo y del estudiante', (
    WidgetTester tester,
  ) async {
    // 1. Crear el reporte del estudiante con todos tus campos obligatorios
    final mockStudent = StudentReport(
      email: 'estudiante@uninorte.edu.co',
      firstName: 'Keiver',
      lastName: 'Miranda',
      evaluationsGiven: 3,
      evaluationsReceived: 3,
      finalGrade: 4.5,
      isComplete: true,
    );

    // 2. Crear el reporte del grupo
    final mockGroup = GroupReport(
      groupId: 'g1',
      groupName: 'Grupo de Desarrollo',
      students: [mockStudent],
    );

    // 3. Configurar el mock para que devuelva estos datos
    when(
      () => mockController.groupReports,
    ).thenReturn(<GroupReport>[mockGroup].obs);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: TeacherReportPage(
          activityId: '1',
          activityName: 'Test',
          categoryId: '1',
        ),
      ),
    );

    await tester.pump();

    // Verificar que el nombre del grupo aparece
    expect(find.text('Grupo de Desarrollo'), findsOneWidget);
    expect(find.text('1 estudiantes'), findsOneWidget);

    // Expandir para ver al estudiante
    await tester.tap(find.text('Grupo de Desarrollo'));
    await tester.pumpAndSettle();

    // Verificar datos del estudiante formateados
    expect(find.text('Keiver Miranda'), findsOneWidget);
    expect(find.text('estudiante@uninorte.edu.co'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('Completado'), findsOneWidget);
  });
}
