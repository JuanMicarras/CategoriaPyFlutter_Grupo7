import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_course_remote_source.dart';

int generateIntId() {
  return DateTime.now().millisecondsSinceEpoch;
}

class CourseRemoteSourceService implements CourseRemoteSource {
  final http.Client httpClient;

  final String token;

  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  CourseRemoteSourceService({required this.token,http.Client? client})
    : httpClient = client ?? http.Client();

  /// 🔥 OBTENER CURSOS
  @override
  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Course'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📚 GET Courses: ${response.body}, code: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Error obteniendo cursos');
    }

    final data = jsonDecode(response.body);

    List records = data is List
        ? data
        : (data['data'] ?? data['records'] ?? []);

    return records.map<Map<String, dynamic>>((e) {
      return {
        "id": e['course_id'].toString(),
        "name": e['course_name'],
        "code": e['code'],
      };
    }).toList();
  }

  /// 🔥 CREAR CURSO
  @override
  Future<Map<String, dynamic>> createCourse(
    String id,
    String name,
    int code,
  ) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/insert'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tableName': 'Course',
        'records': [
          {
            'course_id': generateIntId(), // 🔥 id interno DB
            'course_name': name,
            'code': code,
          },
        ],
      }),
    );

    print('➕ CREATE Course: ${response.body}, code: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error creando curso: ${response.body}');
    }

    return {"id": id, "name": name, "code": code};
  }

  /// 🔥 ACTUALIZAR CURSO
  @override
  Future<void> updateCourse(String id, String name) async {
    final response = await httpClient.put(
      Uri.parse('$baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tableName': 'Course',
        'records': [
          {
            'course_id': int.parse(id),
            'course_name': name,
            // 🔥 NO enviamos code
          },
        ],
      }),
    );

    print('✏️ UPDATE Course: ${response.body}, code: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error actualizando curso');
    }
  }
}
