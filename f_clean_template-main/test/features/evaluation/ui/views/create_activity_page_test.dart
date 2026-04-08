import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Importaciones de tu proyecto
import 'package:peer_sync/features/evaluation/ui/views/create_activity_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';

// --- FAKES PARA MOCKTAIL ---
// Esto soluciona el error de "registerFallbackValue" con BuildContext
class FakeBuildContext extends Fake implements BuildContext {}

// --- MOCK DEL CONTROLADOR ---
class MockEvaluationController extends GetxController
    with Mock
    implements EvaluationController {}

void main() {
  late MockEvaluationController mockController;

  // Se ejecuta una sola vez antes de todos los tests
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockController = MockEvaluationController();

    // 1. MOCK DE CONTROLADORES DE TEXTO
    when(
      () => mockController.nameController,
    ).thenReturn(TextEditingController());
    when(
      () => mockController.descriptionController,
    ).thenReturn(TextEditingController());
    when(
      () => mockController.startDateController,
    ).thenReturn(TextEditingController());
    when(
      () => mockController.endDateController,
    ).thenReturn(TextEditingController());

    // 2. MOCK DE VARIABLES REACTIVAS (Rx)
    when(() => mockController.startDate).thenReturn(DateTime.now().obs);
    when(
      () => mockController.endDate,
    ).thenReturn(DateTime.now().add(const Duration(days: 7)).obs);
    when(() => mockController.isVisible).thenReturn(true.obs);
    when(() => mockController.isLoading).thenReturn(false.obs);

    // 3. MOCK DE MÉTODOS
    when(
      () => mockController.saveActivity(any()),
    ).thenAnswer((_) async => true);
    when(() => mockController.pickStartDate(any())).thenAnswer((_) async {});
    when(() => mockController.pickEndDate(any())).thenAnswer((_) async {});

    // Inyectar el mock
    Get.put<EvaluationController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  // ----------------------------------------------------
  // TEST 1: RENDERIZADO
  // ----------------------------------------------------
  testWidgets(
    '1. Debe renderizar campos de texto y título con nombre de categoría',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: CreateActivityPage(
            categoryId: 'cat_123',
            categoryName: 'Diseño de Sistemas',
          ),
        ),
      );

      expect(
        find.text('Nueva Actividad en Diseño de Sistemas'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Crear Actividad'), findsOneWidget);
    },
  );

  // ----------------------------------------------------
  // TEST 2: SELECTORES DE FECHA (Corregido)
  // ----------------------------------------------------
  testWidgets(
    '2. Debe llamar a pickStartDate al tocar el selector de fecha inicio',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: CreateActivityPage(categoryId: '1', categoryName: 'Test'),
        ),
      );

      // 1. Buscamos el InkWell que envuelve el selector de fecha.
      // Como hay dos iconos de calendario, usamos .first para el de inicio.
      final startCalendarIcon = find.byIcon(Icons.calendar_today).first;

      // 2. Hacemos tap en el icono o en el contenedor que lo rodea
      await tester.tap(startCalendarIcon);

      // 3. pump() es necesario para procesar el frame del tap
      await tester.pump();

      // 4. Verificamos la llamada
      verify(() => mockController.pickStartDate(any())).called(1);
    },
  );

  // ----------------------------------------------------
  // TEST 3: SWITCH DE VISIBILIDAD
  // ----------------------------------------------------
  testWidgets('3. Debe actualizar el valor de isVisible al cambiar el switch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: CreateActivityPage(categoryId: '1', categoryName: 'Test'),
      ),
    );

    final switchFinder = find.byType(Switch);
    await tester.tap(switchFinder);
    await tester.pump();

    expect(mockController.isVisible.value, isFalse);
  });

  // ----------------------------------------------------
  // TEST 4: ESTADO DE CARGA (LOADING)
  // ----------------------------------------------------
  testWidgets(
    '4. Debe mostrar loading en el botón y deshabilitarlo cuando isLoading es true',
    (WidgetTester tester) async {
      when(() => mockController.isLoading).thenReturn(true.obs);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: CreateActivityPage(categoryId: 'cat_abc', categoryName: 'Test'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      verifyNever(() => mockController.saveActivity('cat_abc'));
    },
  );

  // ----------------------------------------------------
  // TEST 5: ACCIÓN DE GUARDAR
  // ----------------------------------------------------
  testWidgets(
    '5. Debe llamar a saveActivity al presionar el botón si no está cargando',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: CreateActivityPage(categoryId: 'cat_abc', categoryName: 'Test'),
        ),
      );

      await tester.tap(find.text('Crear Actividad'));
      await tester.pump();

      verify(() => mockController.saveActivity('cat_abc')).called(1);
    },
  );
}
