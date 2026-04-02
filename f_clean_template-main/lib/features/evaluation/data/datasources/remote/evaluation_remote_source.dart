import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'i_evaluation_remote_source.dart';

class EvaluationRemoteSource implements IEvaluationRemoteSource {
  final http.Client httpClient;
  final String dbUrl = 'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  EvaluationRemoteSource({http.Client? client}) : httpClient = client ?? http.Client();

  @override
  Future<void> createActivity(String categoryId, String name, String description, DateTime startDate, DateTime endDate, bool visibility) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenA');
    if (token == null) throw Exception('No hay sesión activa.');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Convertimos las fechas a UTC ISO-8601 para que PostgreSQL no se queje
    final startIso = startDate.toUtc().toIso8601String();
    final endIso = endDate.toUtc().toIso8601String();

    final res = await httpClient.post(
      Uri.parse('$dbUrl/insert'),
      headers: headers,
      body: jsonEncode({
        'tableName': 'Activity',
        'records': [
          {
            // No mandamos _id para que ROBLE lo genere automáticamente
            'category_id': categoryId,
            'name': name,
            'description': description.isEmpty ? null : description, // Manejo de Nulos
            'start_date': startIso,
            'end_date': endIso,
            'visibility': visibility,
          }
        ]
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error al crear la actividad: ${res.body}');
    }
  }
}