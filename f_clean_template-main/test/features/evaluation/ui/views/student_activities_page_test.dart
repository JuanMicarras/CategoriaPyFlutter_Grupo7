import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// --- Ajusta estas rutas a tu proyecto ---
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';

// 1. Mocks de Controladores y Modelos
class MockEvaluationController extends GetxController with Mock implements EvaluationController {}
class MockActivity extends Mock implements Activity {}

void main() {
  late MockEvaluationController mockController;

  setUp(() {
    mockController = MockEvaluationController();

    // Comportamiento base del controlador para que GetX no lance error
    when(() => mockController.isLoadingActivities).thenReturn(false.obs);
    when(() => mockController.sortedActivities).thenReturn([]);
    
    // Simulamos la carga que se llama en el initState
    when(() => mockController.loadActivities(any())).thenAnswer((_) async {});

    Get.put<EvaluationController>(mockController);
  });

  tearDown(() {
    Get.reset();
  });

  // Widget auxiliar para no repetir código de envoltura en cada test
  Widget createWidgetUnderTest() {
    return const GetMaterialApp(
      home: StudentActivitiesPage(
        categoryId: 'cat_123',
        categoryName: 'Sistemas Distribuidos', 
      ),
    );
  }

  // --- LOS CASOS DE PRUEBA ---

  testWidgets('1. Debe mostrar el título correcto y pedir datos al iniciar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verifica que el nombre de la categoría esté en el AppBar
    expect(find.textContaining('Sistemas Distribuidos'), findsWidgets);
    
    // Verifica que el initState intentó cargar las actividades de esa categoría
    verify(() => mockController.loadActivities('cat_123')).called(1);
  });

  testWidgets('2. Debe mostrar un CircularProgressIndicator cuando está cargando (y no hay datos)', (WidgetTester tester) async {
    // Forzamos el estado de carga
    when(() => mockController.isLoadingActivities).thenReturn(true.obs);
    when(() => mockController.sortedActivities).thenReturn([]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Usamos pump() simple para no quedarnos atrapados en la animación infinita

    // Verificamos que el indicador de carga esté en pantalla
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('3. Debe renderizar la lista de actividades si sortedActivities tiene datos', (WidgetTester tester) async {
    // Creamos una actividad falsa (Mock) y le damos valores
    final fakeActivity = MockActivity();
    when(() => fakeActivity.id).thenReturn('act_1');
    when(() => fakeActivity.name).thenReturn('Taller Final de Arquitectura');
    when(() => fakeActivity.categoryId).thenReturn('cat_123');
    // Para las fechas, devolvemos fechas falsas
    when(() => fakeActivity.startDate).thenReturn(DateTime.now());
    when(() => fakeActivity.endDate).thenReturn(DateTime.now().add(const Duration(days: 3)));

    // Inyectamos la actividad al estado
    when(() => mockController.isLoadingActivities).thenReturn(false.obs);
    when(() => mockController.sortedActivities).thenReturn([fakeActivity]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Ya no debe haber indicador de carga
    expect(find.byType(CircularProgressIndicator), findsNothing);
    
    // Debe aparecer el nombre de nuestra actividad en la pantalla
    expect(find.text('Taller Final de Arquitectura'), findsOneWidget);
    
    // Debe existir un ListView que contenga nuestras tarjetas
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('4. Debe llamar a loadActivities al hacer el gesto de "Pull to Refresh" (deslizar hacia abajo)', (WidgetTester tester) async {
    // Primero necesitamos que haya al menos un elemento para poder hacer scroll
    final fakeActivity = MockActivity();
    when(() => fakeActivity.id).thenReturn('act_1');
    when(() => fakeActivity.name).thenReturn('Actividad a Refrescar');
    when(() => fakeActivity.categoryId).thenReturn('cat_123');
    when(() => fakeActivity.startDate).thenReturn(DateTime.now());
    when(() => fakeActivity.endDate).thenReturn(DateTime.now());
    
    when(() => mockController.isLoadingActivities).thenReturn(false.obs);
    when(() => mockController.sortedActivities).thenReturn([fakeActivity]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Limpiamos el registro de llamadas para no contar el loadActivities que se hizo en el initState
    clearInteractions(mockController);

    // Simulamos el gesto de arrastrar la lista hacia abajo (Pull to refresh)
    await tester.drag(find.text('Actividad a Refrescar'), const Offset(0.0, 300.0));
    await tester.pumpAndSettle();

    // Verificamos que el gesto de recargar efectivamente disparó el método de nuevo
    verify(() => mockController.loadActivities('cat_123')).called(1);
  });
}