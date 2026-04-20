import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_course_remote_source.dart';
import 'package:http/http.dart' as http;

int generateIntId() {
  return DateTime.now().millisecondsSinceEpoch;
}

class CourseRemoteSourceService implements ICourseRemoteSource {
  final http.Client httpClient;

  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  CourseRemoteSourceService({http.Client? client})
      : httpClient = client ?? http.Client();

  /// 🔥 TOKEN DINÁMICO
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenA');
  }

  /// 🔥 HEADERS CENTRALIZADOS
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 🔥 VALIDAR RESPONSE
  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception("401");
    }

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  @override
  Future<void> joinCourse(String code, String email) async {
    final headers = await _getHeaders();

    final courseRes = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Course&code=$code'),
      headers: headers,
    );

    _handleResponse(courseRes);

    final courseData = jsonDecode(courseRes.body);
    List courses = courseData is List
        ? courseData
        : (courseData['data'] ?? courseData['records'] ?? []);

    if (courses.isEmpty) {
      throw Exception('No se encontró un curso con ese código.');
    }

    final courseId = courses.first['course_id'] ?? courses.first['_id'];

    final userRes = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Users&email=$email'),
      headers: headers,
    );

    _handleResponse(userRes);

    final userData = jsonDecode(userRes.body);
    List users = userData is List
        ? userData
        : (userData['data'] ?? userData['records'] ?? []);

    if (users.isEmpty) {
      throw Exception('No se encontró el usuario.');
    }

    final userId = users.first['user_id'] ?? users.first['_id'];

    /// VALIDAR SI YA ESTÁ INSCRITO
    final validationRes = await httpClient.get(
      Uri.parse(
        '$baseUrl/read?tableName=CourseMember&course_id=$courseId&user_id=$userId',
      ),
      headers: headers,
    );

    _handleResponse(validationRes);

    final validationData = jsonDecode(validationRes.body);
    List existingMembers = validationData is List
        ? validationData
        : (validationData['data'] ?? validationData['records'] ?? []);

    if (existingMembers.isNotEmpty) {
      throw Exception('Ya estás inscrito en este curso.');
    }

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

    _handleResponse(insertRes);
  }

  @override
  Future<List<Map<String, dynamic>>> getCourses() async {
    final headers = await _getHeaders();

    final response = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Course'),
      headers: headers,
    );

    _handleResponse(response);

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

  @override
  Future<Map<String, dynamic>> createCourse(
    String id,
    String name,
    int code,
  ) async {
    final headers = await _getHeaders();

    final response = await httpClient.post(
      Uri.parse('$baseUrl/insert'),
      headers: headers,
      body: jsonEncode({
        'tableName': 'Course',
        'records': [
          {
            'course_id': int.parse(id),
            'course_name': name,
            'code': code,
          },
        ],
      }),
    );

    _handleResponse(response);

    return {"id": id, "name": name, "code": code};
  }

  @override
  Future<void> updateCourse(String id, String name) async {
    final headers = await _getHeaders();

    final response = await httpClient.put(
      Uri.parse('$baseUrl/update'),
      headers: headers,
      body: jsonEncode({
        'tableName': 'Course',
        'records': [
          {
            'course_id': int.parse(id),
            'course_name': name,
          },
        ],
      }),
    );

    _handleResponse(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getCoursesByUser() async {
    final headers = await _getHeaders();

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    final userRes = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Users&email=$email'),
      headers: headers,
    );

    _handleResponse(userRes);

    final userData = jsonDecode(userRes.body);
    List users = userData is List
        ? userData
        : (userData['data'] ?? userData['records'] ?? []);

    if (users.isEmpty) {
      throw Exception('No se encontró el usuario');
    }

    final userId = users.first['user_id'] ?? users.first['_id'];

    final memberRes = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=CourseMember&user_id=$userId'),
      headers: headers,
    );

    _handleResponse(memberRes);

    final memberData = jsonDecode(memberRes.body);
    List members = memberData is List
        ? memberData
        : (memberData['data'] ?? memberData['records'] ?? []);

    List<Map<String, dynamic>> courses = [];

    for (var member in members) {
      final courseId = member['course_id'];

      final courseRes = await httpClient.get(
        Uri.parse('$baseUrl/read?tableName=Course&course_id=$courseId'),
        headers: headers,
      );

      _handleResponse(courseRes);

      final courseData = jsonDecode(courseRes.body);

      List records = courseData is List
          ? courseData
          : (courseData['data'] ?? courseData['records'] ?? []);

      if (records.isNotEmpty) {
        final e = records.first;

        courses.add({
          "id": e['course_id'].toString(),
          "name": e['course_name'],
          "code": e['code'],
        });
      }
    }

    return courses;
  }
}
