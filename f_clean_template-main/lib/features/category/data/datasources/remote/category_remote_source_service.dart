import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_category_remote_source.dart';

class CategoryRemoteSourceService implements ICategoryRemoteSource {
  final http.Client httpClient;
  final String token;

  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  CategoryRemoteSourceService({required this.token, http.Client? client})
      : httpClient = client ?? http.Client();

  @override
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(
      String courseId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Category&course_id=$courseId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📂 GET Categories: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error obteniendo categorías');
    }

    final data = jsonDecode(response.body);

    List records = data is List
        ? data
        : (data['data'] ?? data['records'] ?? []);

    return records.map<Map<String, dynamic>>((e) {
      return {
        "id": e['category_id'].toString(),
        "name": e['category_name'],
        "course_id": e['course_id'].toString(),
      };
    }).toList();
  }
}