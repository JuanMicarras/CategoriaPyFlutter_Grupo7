import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/data/repositories/evaluation_repository_impl.dart';
import 'package:peer_sync/features/evaluation/data/datasources/remote/evaluation_remote_source.dart';

// 1. MOCKS DE LA CAPA DE RED (INTERNET)
class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockHttpClient;
  late EvaluationRemoteSource remoteSource;
  late EvaluationRepositoryImpl repository;
  late EvaluationController controller;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'tokenA': 'fake-token-123'});

    mockHttpClient = MockHttpClient();
    remoteSource = EvaluationRemoteSource(client: mockHttpClient); 
    repository = EvaluationRepositoryImpl(remoteSource);
    controller = EvaluationController(repository);

    Get.put<EvaluationController>(controller);
  });

  tearDown(() {
    Get.reset(); 
    clearInteractions(mockHttpClient); 
  });

  // =======================================================================
  // PRUEBA 1: INTEGRACIÓN CON LA INTERFAZ DE USUARIO (UI)
  // =======================================================================
  testWidgets('1. Nivel 3: La UI se integra con el Repositorio y dibuja actividades', (WidgetTester tester) async {
    final mockRobleResponse = [
      {
        '_id': 'act_999',
        'category_id': 'cat_123',
        'name': 'Exposición Final',
        'description': 'Test',
        'start_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'visibility': true
      }
    ];

    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(jsonEncode({'data': mockRobleResponse}), 200));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: StudentActivitiesPage(categoryId: 'cat_123', categoryName: 'Pruebas de Software'),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); 

    expect(find.textContaining('Pruebas de Software'), findsWidgets);
    expect(find.text('Exposición Final'), findsOneWidget); 
    verify(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).called(1);
  });

  // =======================================================================
  // PRUEBA 2: MAPEO DE CRITERIOS (Lectura simple)
  // =======================================================================
  test('2. Nivel 3: El Repositorio lee y formatea Criterios de evaluación desde la API', () async {
    final mockCriteriaJson = [
      {
        '_id': 'crit_1',
        'activity_id': 'act_123',
        'name': 'Puntualidad',
        'max_score': 5.0
      }
    ];

    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(jsonEncode({'data': mockCriteriaJson}), 200));

    final criteriaList = await repository.getCriteria('act_123');

    expect(criteriaList.length, 1);
    expect(criteriaList.first.name, 'Puntualidad');
    expect(criteriaList.first.maxScore, 5.0); 
  });

  // =======================================================================
  // PRUEBA 3: MAPEO DE COMPAÑEROS (Lectura múltiple y filtrado)
  // =======================================================================
  test('3. Nivel 3: El Repositorio carga la lista de compañeros (Peers) del grupo', () async {
    
    final mockGenericData = [
      {
        '_id': 'user_1',
        'group_id': 'group_1',
        'student_id': 'juan@uninorte.edu.co',
        'email': 'juan@uninorte.edu.co',
        'first_name': 'Juan',
        'name': 'Juan', // Por si lo busca como 'name'
        'last_name': 'Perez',
        'code': '123456'
      }
    ];

    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(jsonEncode({'data': mockGenericData}), 200));

    final peers = await repository.getPeers('cat_123', 'mi_correo@uninorte.edu.co');

    expect(peers.isNotEmpty, true);
    expect(peers.first.email, 'juan@uninorte.edu.co');
  });

  // =======================================================================
  // PRUEBA 4: ENVÍO DE CALIFICACIONES (Petición POST y GET)
  // =======================================================================
  test('4. Nivel 3: El Repositorio envía la evaluación correctamente hacia Roble (Método POST)', () async {
    
    int evaluationGetCallCount = 0; 

    // 1. Configuramos el GET para que sea inteligente
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((invocation) async {
      
      final uri = invocation.positionalArguments[0] as Uri;
      final tableName = uri.queryParameters['tableName'];

      if (tableName == 'Evaluation') {
        evaluationGetCallCount++;
        
        if (evaluationGetCallCount == 1) {
          // Primer GET: Validación de duplicados. Devolvemos vacío.
          return http.Response(jsonEncode({'data': []}), 200);
        } else {
          // Segundo GET: Buscar el ID insertado. Devolvemos el ID falso.
          return http.Response(jsonEncode({'data': [{'_id': 'eval_123'}]}), 200);
        }
      }

      if (tableName == 'Group' || tableName == 'GroupMember') {
        // Tu código busca el grupo del estudiante, le devolvemos uno falso.
        return http.Response(jsonEncode({'data': [{'_id': 'group_1'}]}), 200);
      }

      return http.Response(jsonEncode({'data': []}), 200);
    });

    // 2. Simulamos el POST (ya no importa qué devuelve porque tu código lee con GET)
    when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(jsonEncode({'success': true}), 200));

    // 3. Ejecutamos la función
    await repository.submitEvaluation(
      'act_123',
      'cat_123',
      'yo@uninorte.edu.co',
      'amigo@uninorte.edu.co',
      'Excelente compañero',
      {'crit_1': 5.0, 'crit_2': 4.5}, 
    );

    // 4. Verificamos que se hayan disparado las peticiones POST (Cabecera y Criterios)
    verify(() => mockHttpClient.post(
      any(), 
      headers: any(named: 'headers'), 
      body: any(named: 'body')
    )).called(greaterThanOrEqualTo(1));
  });
}