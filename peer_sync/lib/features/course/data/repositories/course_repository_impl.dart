import 'package:peer_sync/features/course/domain/models/course.dart';
import 'package:peer_sync/features/course/domain/repositories/i_course_repository.dart';
import 'package:peer_sync/features/course/data/datasources/remote/i_course_remote_source.dart';
import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CourseRepositoryImpl implements ICourseRepository {
  final ICourseRemoteSource _dataSource;
  final IAuthRepository _authRepository;

  CourseRepositoryImpl(this._dataSource, this._authRepository);

  @override
  Future<void> joinCourse(String code, String email) async {
    print("📡 JOIN COURSE → API");
    await _authRepository.safeRequest(() {
      return _dataSource.joinCourse(code, email);
    });
  }

  @override
  Future<List<Course>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      print("🌐 GET COURSES → API CALL");

      final response = await _authRepository.safeRequest(() {
        return _dataSource.getCourses();
      });

      final courses = response.map<Course>((e) {
        return Course(id: e['id'], name: e['name'], code: e['code']);
      }).toList();

      /// 🔥 Guardar en cache
      await prefs.setString('courses', jsonEncode(response));
      print("💾 CACHE SAVED (courses)");

      return courses;
    } catch (e) {
      print("❌ API FALLÓ → usando CACHE");

      /// 🔥 fallback local
      final stored = prefs.getString('courses');

      if (stored == null) {
        print("⚠️ NO HAY CACHE");
        return [];
      }

      print("⚡ CACHE HIT (courses)");

      final List decoded = jsonDecode(stored);

      return decoded.map<Course>((e) {
        return Course(id: e['id'], name: e['name'], code: e['code']);
      }).toList();
    }
  }

  @override
  Future<bool> createCourse(Course course) async {
    try {
      print("🌐 CREATE COURSE → API");

      final response = await _authRepository.safeRequest(() {
        return _dataSource.createCourse(course.id, course.name, course.code);
      });

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      List list = [];

      if (stored != null) {
        list = jsonDecode(stored);
        print("⚡ CACHE LOAD antes de insertar");
      }

      list.add(response);

      await prefs.setString('courses', jsonEncode(list));
      print("💾 CACHE UPDATED (course creado)");

      return true;
    } catch (e) {
      print("❌ ERROR creando curso: $e");
      return false;
    }
  }

  @override
  Future<bool> updateCourse(Course course) async {
    try {
      print("🌐 UPDATE COURSE → API");

      await _authRepository.safeRequest(() {
        return _dataSource.updateCourse(course.id, course.name);
      });

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      if (stored == null) {
        print("⚠️ No hay cache para actualizar");
        return true;
      }

      List list = jsonDecode(stored);

      list = list.map((e) {
        if (e['id'] == course.id) {
          return {"id": course.id, "name": course.name, "code": course.code};
        }
        return e;
      }).toList();

      await prefs.setString('courses', jsonEncode(list));
      print("💾 CACHE UPDATED (course actualizado)");

      return true;
    } catch (e) {
      print("❌ ERROR actualizando curso: $e");
      return false;
    }
  }

  @override
  Future<List<Course>> getCoursesByUser() async {
    final prefs = await SharedPreferences.getInstance();

    /// 🔥 Obtener email del usuario actual
    final userEmail = await _authRepository.getCurrentUserEmail();

    if (userEmail == null) {
      print("❌ No hay usuario logueado");
      return [];
    }

    final cacheKey = 'courses_user_$userEmail';

    /// 🔥 1. INTENTAR LEER CACHE PRIMERO (FAST LOAD)
    final cached = prefs.getString(cacheKey);

    if (cached != null) {
      print("⚡ CARGANDO CURSOS DESDE CACHE ($userEmail)");

      final List decoded = jsonDecode(cached);

      /// 🔥 REFRESH EN BACKGROUND (sin bloquear UI)
      _refreshCoursesInBackground(userEmail, cacheKey);

      return decoded.map<Course>((e) {
        return Course(id: e['id'], name: e['name'], code: e['code']);
      }).toList();
    }

    /// 🔥 2. SI NO HAY CACHE → API
    print("🌐 GET COURSES BY USER → API ($userEmail)");

    final response = await _authRepository.safeRequest(() {
      return _dataSource.getCoursesByUser();
    });

    /// 🔥 Guardar cache
    await prefs.setString(cacheKey, jsonEncode(response));
    print("💾 CACHE SAVED ($userEmail)");

    return response.map<Course>((e) {
      return Course(id: e['id'], name: e['name'], code: e['code']);
    }).toList();
  }

  void _refreshCoursesInBackground(String userEmail, String cacheKey) async {
    try {
      print("🔄 REFRESH EN BACKGROUND ($userEmail)");

      final response = await _authRepository.safeRequest(() {
        return _dataSource.getCoursesByUser();
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(response));

      print("✅ CACHE ACTUALIZADA ($userEmail)");
    } catch (e) {
      print("⚠️ ERROR REFRESH BACKGROUND: $e");
    }
  }
}
