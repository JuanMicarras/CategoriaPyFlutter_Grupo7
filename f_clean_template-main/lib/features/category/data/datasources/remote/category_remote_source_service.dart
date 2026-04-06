import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
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

    if (response.statusCode != 200) {
      throw Exception('Error obteniendo categorías');
    }

    final data = jsonDecode(response.body);

    List records = data is List
        ? data
        : (data['data'] ?? data['records'] ?? []);

    return records.map<Map<String, dynamic>>((e) {
      return {
        "id": (e['category_id'] ?? e['_id']).toString(),
        "name": e['category_name'],
        "course_id": e['course_id'].toString(),
      };
    }).toList();
  }

  /// 🔥 FILTRADO POR ESTUDIANTE
  @override
  Future<List<Map<String, dynamic>>> getCategoriesByStudent(
      String courseId) async {
    final email = Get.find<AuthController>().user?.email ?? '';
    // print("📧 Email del usuario: $email");
    /// 1. 🔥 GROUP MEMBERS
    final memberResponse = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=GroupMember&email=$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (memberResponse.statusCode != 200) {
      throw Exception('Error obteniendo group members');
    }

    final memberData = jsonDecode(memberResponse.body);

    List memberRecords = memberData is List
        ? memberData
        : (memberData['data'] ?? memberData['records'] ?? []);

    final groupIds = memberRecords
        .map((e) => e['group_id'].toString())
        .toSet()
        .toList();

    if (groupIds.isEmpty) return [];

    /// 2. 🔥 GROUPS
    final groupResponse = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Group'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (groupResponse.statusCode != 200) {
      throw Exception('Error obteniendo grupos');
    }

    final groupData = jsonDecode(groupResponse.body);

    List groupRecords = groupData is List
        ? groupData
        : (groupData['data'] ?? groupData['records'] ?? []);


    final userGroups = groupRecords.where((g) =>
        groupIds.contains((g['_id']).toString()));

    final categoryIds = userGroups
        .map((g) => g['category_id'].toString())
        .toSet()
        .toList();

    if (categoryIds.isEmpty) return [];

    /// 3. 🔥 CATEGORIES
    final categoryResponse = await httpClient.get(
      Uri.parse('$baseUrl/read?tableName=Category&course_id=$courseId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (categoryResponse.statusCode != 200) {
      throw Exception('Error obteniendo categorías');
    }

    final categoryData = jsonDecode(categoryResponse.body);

    List categoryRecords = categoryData is List
        ? categoryData
        : (categoryData['data'] ?? categoryData['records'] ?? []);

    final filtered = categoryRecords.where((c) =>
        categoryIds.contains(
            (c['category_id'] ?? c['_id']).toString()));

    return filtered.map<Map<String, dynamic>>((e) {
      return {
        "id": (e['category_id'] ?? e['_id']).toString(),
        "name": e['category_name'],
        "course_id": e['course_id'].toString(),
      };
    }).toList();
  }
}
