import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'i_groups_remote_source.dart';

class GroupsRemoteSource implements IGroupsRemoteSource {
  final http.Client httpClient;
  final String dbUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';

  GroupsRemoteSource({http.Client? client})
    : httpClient = client ?? http.Client();

  // 1. REFACTORIZADO: Usa parámetros seguros para evitar el Error 500 por espacios
  Future<List<dynamic>> _readTable(
    String tableName,
    Map<String, String> queryParams,
    Map<String, String> headers,
  ) async {
    // Esto asegura que los espacios y caracteres especiales se codifiquen a %20 etc.
    final uri = Uri.parse(
      '$dbUrl/read',
    ).replace(queryParameters: {'tableName': tableName, ...queryParams});

    final res = await httpClient.get(uri, headers: headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is List ? data : (data['data'] ?? data['records'] ?? []);
    } else {
  
      return [];
    }
  }

  // 2. REFACTORIZADO: Agregamos impresiones para saber exactamente dónde falla
  Future<void> _insertTable(
    String tableName,
    List<Map<String, dynamic>> records,
    Map<String, String> headers,
  ) async {
    final bodyStr = jsonEncode({'tableName': tableName, 'records': records});

    final res = await httpClient.post(
      Uri.parse('$dbUrl/insert'),
      headers: headers,
      body: bodyStr,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      
      throw Exception('Error al insertar en $tableName: ${res.body}');
    } else {
      print('respuesta exitosa al insertar en $tableName: ${res.body}');
    }
  }

  @override
  Future<void> importGroupsFromCsv(String courseId, String csvString) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenA');
    if (token == null) throw Exception('No hay sesión activa.');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 1. Convertir el texto CSV a una lista de filas
    final converter = CsvDecoder();
    List<List<dynamic>> rowsAsListOfValues = converter.convert(csvString);

    if (rowsAsListOfValues.length <= 1) {
      throw Exception('El archivo CSV está vacío o no tiene datos válidos.');
    }

    final header = rowsAsListOfValues[0]
        .map((e) => e.toString().trim())
        .toList();
    final colCatName = header.indexOf('Group Category Name');
    final colGroupName = header.indexOf('Group Name');
    final colFirstName = header.indexOf('First Name');
    final colLastName = header.indexOf('Last Name');
    final colEmail = header.indexOf('Email Address');

    if (colCatName == -1 || colGroupName == -1 || colEmail == -1) {
      throw Exception('El CSV no tiene las columnas requeridas.');
    }

    // Transformamos el courseId a número (bigint en BD) para evitar error 500 en el insert
    final intCourseId = int.tryParse(courseId) ?? 0;

    Map<String, String> categoryIds = {};
    Map<String, String> groupIds = {};

    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      final row = rowsAsListOfValues[i];
      if (row.length < header.length) continue;

      // Limpiamos los saltos de línea ocultos (\r) que a veces traen los CSV y rompen el JSON
      final catName = row[colCatName].toString().replaceAll('\r', '').trim();
      final groupName = row[colGroupName]
          .toString()
          .replaceAll('\r', '')
          .trim();
      final firstName = row[colFirstName]
          .toString()
          .replaceAll('\r', '')
          .trim();
      final lastName = row[colLastName].toString().replaceAll('\r', '').trim();
      final email = row[colEmail].toString().replaceAll('\r', '').trim();

      if (catName.isEmpty || groupName.isEmpty || email.isEmpty) continue;

      

      // ==========================================
      // FASE A: GESTIÓN DE LA CATEGORÍA
      // ==========================================
      if (!categoryIds.containsKey(catName)) {
        var existingCat = await _readTable('Category', {
          'course_id': courseId, // Roble lo acepta como string en el GET
          'category_name': catName,
        }, headers);

        if (existingCat.isEmpty) {
          await _insertTable('Category', [
            {
              'course_id': intCourseId,
              'category_name': catName,
            }, // Aquí va como int
          ], headers);

          existingCat = await _readTable('Category', {
            'course_id': courseId,
            'category_name': catName,
          }, headers);
        }
        categoryIds[catName] = existingCat.first['_id'];
      }
      final currentCatId = categoryIds[catName]!;

      // ==========================================
      // FASE B: GESTIÓN DEL GRUPO
      // ==========================================
      final groupKey = '$currentCatId-$groupName';

      if (!groupIds.containsKey(groupKey)) {
        var existingGroup = await _readTable('Group', {
          'category_id': currentCatId,
          'group_name': groupName,
        }, headers);

        if (existingGroup.isEmpty) {
          await _insertTable('Group', [
            {'category_id': currentCatId, 'group_name': groupName},
          ], headers);

          existingGroup = await _readTable('Group', {
            'category_id': currentCatId,
            'group_name': groupName,
          }, headers);
        }
        groupIds[groupKey] = existingGroup.first['_id'];
      }
      final currentGroupId = groupIds[groupKey]!;

      // ==========================================
      // FASE C: GESTIÓN DEL MIEMBRO
      // ==========================================
      var existingMember = await _readTable('GroupMember', {
        'group_id': currentGroupId,
        'email': email,
      }, headers);

      if (existingMember.isEmpty) {
        await _insertTable('GroupMember', [
          {
            'group_id': currentGroupId,
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
          },
        ], headers);
      }
    }
  }
}
