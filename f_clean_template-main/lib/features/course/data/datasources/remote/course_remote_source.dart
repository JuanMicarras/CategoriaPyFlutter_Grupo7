/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'i_course_remote_source.dart';

class CourseRemoteSource implements ICourseRemoteSource {
  final http.Client httpClient;
  final String dbUrl = 'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  CourseRemoteSource({http.Client? client}) : httpClient = client ?? http.Client();

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
      Uri.parse('$dbUrl/read?tableName=Course&code=$code'),
      headers: headers,
    );
    
    final courseData = jsonDecode(courseRes.body);
    List courses = courseData is List ? courseData : (courseData['data'] ?? courseData['records'] ?? []);
    if (courses.isEmpty) throw Exception('No se encontró un curso con ese código.');
    
    final courseId = courses.first['course_id'] ?? courses.first['_id'];

    // 3. BUSCAR EL USUARIO ACTUAL
    final userRes = await httpClient.get(
      Uri.parse('$dbUrl/read?tableName=Users&email=$email'),
      headers: headers,
    );

    final userData = jsonDecode(userRes.body);
    List users = userData is List ? userData : (userData['data'] ?? userData['records'] ?? []);
    if (users.isEmpty) throw Exception('Error interno: No se encontró tu perfil de usuario.');
    
    final userId = users.first['user_id'] ?? users.first['_id'];

    // =========================================================
    // 3.5 NUEVO: VALIDAR SI YA ESTÁ INSCRITO EN EL CURSO
    // Le pedimos a Roble que busque si ya existe esa combinación exacta
    final validationRes = await httpClient.get(
      Uri.parse('$dbUrl/read?tableName=CourseMember&course_id=$courseId&user_id=$userId'),
      headers: headers,
    );

    if (validationRes.statusCode == 200) {
      final validationData = jsonDecode(validationRes.body);
      List existingMembers = validationData is List ? validationData : (validationData['data'] ?? validationData['records'] ?? []);
      
      // Si la lista no está vacía, significa que ya está en el curso
      if (existingMembers.isNotEmpty) {
        throw Exception('Ya estás inscrito en este curso.'); // El Controller atrapará esto
      }
    }
    // =========================================================

    // 4. INSERTAR EN LA TABLA CourseMember (Solo llega aquí si no saltó la excepción anterior)
    final insertRes = await httpClient.post(
      Uri.parse('$dbUrl/insert'),
      headers: headers,
      body: jsonEncode({
        'tableName': 'CourseMember',
        'records': [
          {
            'course_id': courseId,
            'user_id': userId,
          }
        ]
      }),
    );

    if (insertRes.statusCode != 200 && insertRes.statusCode != 201) {
      throw Exception('Error al inscribirte al curso: ${insertRes.body}');
    }
  }

  
}

*/