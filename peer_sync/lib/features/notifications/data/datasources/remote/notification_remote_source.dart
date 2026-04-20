import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRemoteSource {
  final http.Client httpClient;
  final String dbUrl = 'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  NotificationRemoteSource({http.Client? client}) : httpClient = client ?? http.Client();

  Future<List<dynamic>> getUserNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenA');
    
    final uri = Uri.parse('$dbUrl/read').replace(queryParameters: {
      'tableName': 'Notification',
      'user_id': userId,
    });

    final res = await httpClient.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['data'] ?? data['records'] ?? []);
    } else {
      throw Exception('Error al obtener notificaciones');
    }
  }

  // MÉTODO ACTUALIZADO SEGÚN LA DOCUMENTACIÓN DE ROBLE
  Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenA');
    
    final res = await httpClient.put(
      Uri.parse('$dbUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tableName': 'Notification',
        'idColumn': '_id',
        'idValue': notificationId,
        'updates': {
          'is_read': true
        }
      }),
    );
    
    if (res.statusCode != 200) {
      print('Aviso: No se pudo marcar como leída. Error: ${res.body}');
    }
  }
}