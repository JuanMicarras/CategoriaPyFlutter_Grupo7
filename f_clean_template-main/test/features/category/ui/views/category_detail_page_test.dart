import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Importaciones de tu proyecto
import 'package:peer_sync/features/category/ui/views/category_detail_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/features/category/ui/widgets/create_activity_modal.dart';

// --- FAKES Y MOCKS ---
class FakeBuildContext extends Fake implements BuildContext {}

class MockEvaluationController extends GetxController
    with Mock
    implements EvaluationController {}

void main() {
  late MockEvaluationController mockController;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockController = MockEvaluationController();

    // 1. MOCKS DE ESTADOS REACTIVOS
    when(() => mockController.isLoadingTeacherActivities).thenReturn(false.obs);
    when(() => mockController.teacherActivities).thenReturn(<Activity>[].obs);
    when(() => mockController.isVisible).thenReturn(true.obs);
    when(() => mockController.isLoading).thenReturn(false.obs);

    // 2. MOCKS DE CONTROLADORES DE TEXTO (Necesarios para el modal)
    when(() => mockController.nameController).thenReturn(TextEditingController());
    when(() => mockController.descriptionController).thenReturn(TextEditingController());
    when(() => mockController.startDateController).thenReturn(TextEditingController());
    when(() => mockController.endDateController).thenReturn(TextEditingController());
    when(() => mockController.startTimeController).thenReturn(TextEditingController());
    when(() => mockController.endTimeController).thenReturn(TextEditingController());

    // 3. MOCKS DE MÉTODOS Y CARGA
    when(() => mockController.loadTeacherActivities(any())).thenAnswer((_) async {});
    when(() => mockController.saveActivity(any())).thenAnswer((_) async => true);
    
    // Mock de los pickers para que no fallen al abrirlos
    when(() => mockController.pickStartDate(any())).thenAnswer((_) async {});
    when(() => mockController.pickEndDate(any())).thenAnswer((_) async {});
    when(() => mockController.pickStartTime(any())).thenAnswer((_) async {});
    when(() => mockController.pickEndTime(any())).thenAnswer((_) async {});

    Get.put<EvaluationController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  // ----------------------------------------------------
  // TEST 1: ESTADO DE CARGA
  // ----------------------------------------------------
  testWidgets('1. Debe mostrar un indicador de carga mientras carga actividades', (WidgetTester tester) async {
    when(() => mockController.isLoadingTeacherActivities).thenReturn(true.obs);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ----------------------------------------------------
  // TEST 2: LISTA VACÍA
  // ----------------------------------------------------
  testWidgets('2. Debe mostrar mensaje de lista vacía cuando no hay actividades', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    await tester.pump(); // Procesar el frame inicial

    expect(find.textContaining("No hay actividades creadas aún"), findsOneWidget);
    verify(() => mockController.loadTeacherActivities('1')).called(1);
  });

  // ----------------------------------------------------
  // TEST 3: LISTA CON DATOS (Corregido)
  // ----------------------------------------------------
  testWidgets('3. Debe renderizar la lista de actividades correctamente', (WidgetTester tester) async {
    final mockActivity = Activity(
      id: 'act_1',
      categoryId: 'cat_123',
      name: 'Exposición Final',
      description: 'Test Description',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1)),
      visibility: true,
    );

    // Seteamos el mock con la actividad
    when(() => mockController.teacherActivities).thenReturn(<Activity>[mockActivity].obs);
    
    // Mockeamos la data que el Card espera recibir para pintar
    when(() => mockController.getTeacherActivityUIData(any())).thenReturn((
      month: 'ABR',
      day: '08',
      statusTag: 'En curso',
      statusDetail: '• Cierra 10:00 PM',
      isExpired: false,
    ));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    // pumpAndSettle para asegurar que GetX actualice el Obx con la lista
    await tester.pumpAndSettle();

    // Verificamos por texto parcial para evitar errores de mayúsculas/minúsculas
    expect(find.textContaining('Exposición Final'), findsOneWidget);
    expect(find.text('En curso'), findsOneWidget);
    expect(find.byType(ActivityStatusCard), findsOneWidget);
  });

  // ----------------------------------------------------
  // TEST 4: APERTURA DEL MODAL (Corregido)
  // ----------------------------------------------------
  testWidgets('4. Debe abrir el modal de creación al presionar el FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: CategoryDetailPage(categoryId: '1', categoryName: 'Mantenimiento'),
      ),
    );

    // Presionamos el botón de añadir
    await tester.tap(find.byType(FloatingActionButton));
    
    // Esperamos a que la animación de Get.dialog termine
    await tester.pumpAndSettle();

    // Verificamos que el widget del modal existe en el árbol
    expect(find.byType(CreateActivityModal), findsOneWidget);
  });
}