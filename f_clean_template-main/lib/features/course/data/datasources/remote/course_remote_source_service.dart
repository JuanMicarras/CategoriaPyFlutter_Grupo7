import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_course_remote_source.dart';
import 'package:http/http.dart' as http;

int generateIntId() {
  return DateTime.now().millisecondsSinceEpoch;
}

class CourseRemoteSourceService implements ICourseRemoteSource {
  final http.Client httpClient;

  final String token;

  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  CourseRemoteSourceService({required this.token, http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<void> joinCourse(String code, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenA');
    if (token == null) throw Exception('No hay sesión activa.');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 2. BUSCAR EL CURSO POR SU CÓDIGO
    final courseRes = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Course&code=$code'),
      headers: headers,
    );

    final courseData = jsonDecode(courseRes.body);
    List courses = courseData is List
        ? courseData
        : (courseData['data'] ?? courseData['records'] ?? []);
    if (courses.isEmpty)
      throw Exception('No se encontró un curso con ese código.');

    final courseId = courses.first['course_id'] ?? courses.first['_id'];

    // 3. BUSCAR EL USUARIO ACTUAL
    final userRes = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Users&email=$email'),
      headers: headers,
    );

    final userData = jsonDecode(userRes.body);
    List users = userData is List
        ? userData
        : (userData['data'] ?? userData['records'] ?? []);
    if (users.isEmpty)
      throw Exception('Error interno: No se encontró tu perfil de usuario.');

    final userId = users.first['user_id'] ?? users.first['_id'];

    // =========================================================
    // 3.5 NUEVO: VALIDAR SI YA ESTÁ INSCRITO EN EL CURSO
    // Le pedimos a Roble que busque si ya existe esa combinación exacta
    final validationRes = await httpClient.get(
      Uri.parse(
        '$baseUrl/read?tableName=CourseMember&course_id=$courseId&user_id=$userId',
      ),
      headers: headers,
    );

    if (validationRes.statusCode == 200) {
      final validationData = jsonDecode(validationRes.body);
      List existingMembers = validationData is List
          ? validationData
          : (validationData['data'] ?? validationData['records'] ?? []);

      // Si la lista no está vacía, significa que ya está en el curso
      if (existingMembers.isNotEmpty) {
        throw Exception(
          'Ya estás inscrito en este curso.',
        ); // El Controller atrapará esto
      }
    }
    // =========================================================

    // 4. INSERTAR EN LA TABLA CourseMember (Solo llega aquí si no saltó la excepción anterior)
    final insertRes = await httpClient.post(
      Uri.parse('$baseUrl/insert'),
      headers: headers,
      body: jsonEncode({
        'tableName': 'CourseMember',
        'records': [
          {'course_id': courseId, 'user_id': userId},
        ],
      }),
    );

    if (insertRes.statusCode != 200 && insertRes.statusCode != 201) {
      throw Exception('Error al inscribirte al curso: ${insertRes.body}');
    }
  }

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
