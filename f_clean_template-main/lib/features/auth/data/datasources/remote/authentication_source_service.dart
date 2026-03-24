import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_authentication_source.dart';
int generateIntId() {
  return DateTime.now().millisecondsSinceEpoch;
}
class AuthenticationSourceService implements IAuthenticationSource {
  final http.Client httpClient;
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/peer_sync_2e18809588';

  AuthenticationSourceService({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    // 1. HACEMOS LOGIN EN AUTH PARA OBTENER LOS TOKENS
    final authResponse = await httpClient.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('🔐 Intento de login, respuesta: ${authResponse.body}, code: ${authResponse.statusCode}');
    if (authResponse.statusCode != 200 && authResponse.statusCode != 201) {
      throw Exception('Error en Login: ${authResponse.body}');
    }

    final authData = jsonDecode(authResponse.body);
    final accessToken = authData['accessToken'];

    // 2. BUSCAMOS AL USUARIO EN LA TABLA "Users"
    final dbUrl = 'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';
    
    final dbResponse = await httpClient.get(
      // Pasamos el email como Query Parameter para filtrar
      Uri.parse('$dbUrl/read?tableName=Users&email=$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Requiere token válido
      },
    );
    print('🔍 Consulta a tabla Users, respuesta: ${dbResponse.body}, code: ${dbResponse.statusCode}');
    if (dbResponse.statusCode == 200) {
      final dbData = jsonDecode(dbResponse.body);
      
      // ROBLE suele devolver un arreglo con los resultados. Lo manejamos de forma segura.
      List records = dbData is List ? dbData : (dbData['data'] ?? dbData['records'] ?? []);

      if (records.isNotEmpty) {
        final userRecord = records.first;
        final firstName = userRecord['first_name'] ?? '';
        final lastName = userRecord['last_name'] ?? '';
        
        // 3. INYECTAMOS LOS DATOS DE LA BD AL RESULTADO FINAL
        authData['name'] = '$firstName $lastName'.trim();
        authData['role'] = userRecord['role'] ?? 'student';
      } else {
        // Fallback: Si el usuario existe en Auth pero no en la tabla Users
        authData['name'] = email.split('@').first;
        authData['role'] = 'student';
      }
    } else {
      // Si falla la consulta a la BD, ponemos valores por defecto para no romper el login
      authData['name'] = email.split('@').first;
      authData['role'] = 'student';
    }

    // Retorna { accessToken, refreshToken, name, role }
    return authData; 
  }

  @override
  Future<Map<String, dynamic>> signUp(String email, String password, String name) async {
    // 1. CREAR CUENTA EN AUTH (signup-direct)
    final authResponse = await httpClient.post(
      Uri.parse('$baseUrl/signup-direct'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (authResponse.statusCode != 200 && authResponse.statusCode != 201) {
      throw Exception('Error en registro: ${authResponse.body}');
    }

    // 2. INICIAR SESIÓN AUTOMÁTICAMENTE PARA OBTENER EL TOKEN
    final loginResponse = await httpClient.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (loginResponse.statusCode != 200 && loginResponse.statusCode != 201) {
      throw Exception('Cuenta creada, pero falló el auto-login: ${loginResponse.body}');
    }

    // Extraemos el token del login exitoso
    final authData = jsonDecode(loginResponse.body);
    final accessToken = authData['accessToken']; 

    // 3. PREPARAR DATOS PARA LA TABLA USERS
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // 4. INSERTAR EN LA BASE DE DATOS
    final dbUrl = 'https://roble-api.openlab.uninorte.edu.co/database/peer_sync_2e18809588';
    final dbResponse = await httpClient.post(
      Uri.parse('$dbUrl/insert'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', 
      },
      body: jsonEncode({
        'tableName': 'Users',
        'records': [
          {
            'user_id': generateIntId(), 
            'email': email,
            'first_name': firstName,
            'last_name': lastName,
            'role': 'student'
          }
        ]
      }),
    );

    if (dbResponse.statusCode == 200 || dbResponse.statusCode == 201) {
      print('✅ Usuario registrado en tabla Users, respuesta: ${dbResponse.body}, code: ${dbResponse.statusCode}');
      return authData; 
    } else {
      throw Exception('Cuenta creada, pero falló al guardar en tabla Users: ${dbResponse.body}');
    }
  }

}
