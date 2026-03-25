import 'package:peer_sync/features/course/domain/models/course.dart';
import 'package:peer_sync/features/course/domain/repositories/i_course_repository.dart';
import 'package:peer_sync/features/course/data/datasources/remote/i_course_remote_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CourseRepositoryImpl implements ICourseRepository {
  final ICourseRemoteSource _dataSource;

  CourseRepositoryImpl(this._dataSource);

  @override
  Future<void> joinCourse(String code, String email) async {
    await _dataSource.joinCourse(code, email);
  }

  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await _dataSource.getCourses();

      final courses = response.map<Course>((e) {
        return Course(
          id: e['id'],
          name: e['name'],
          code: e['code'],
        );
      }).toList();

      /// 2. Guardar en local (cache)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('courses', jsonEncode(response));

      return courses;
    } catch (e) {
      /// 🔥 fallback: leer local
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      if (stored == null) return [];

      final List decoded = jsonDecode(stored);

      return decoded.map<Course>((e) {
        return Course(
          id: e['id'],
          name: e['name'],
          code: e['code'],
        );
      }).toList();
    }
  }

  /// 🔥 CREAR CURSO
  @override
  Future<bool> createCourse(Course course) async {
    try {
      final response = await _dataSource.createCourse(
        course.id,
        course.name,
        course.code,
      );

      /// guardar local
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      List list = [];

      if (stored != null) {
        list = jsonDecode(stored);
      }

      list.add(response);

      await prefs.setString('courses', jsonEncode(list));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🔥 ACTUALIZAR CURSO
  @override
  Future<bool> updateCourse(Course course) async {
    try {
      await _dataSource.updateCourse(
        course.id,
        course.name,
      );

      /// actualizar local
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      if (stored == null) return true;

      List list = jsonDecode(stored);

      list = list.map((e) {
        if (e['id'] == course.id) {
          return {
            "id": course.id,
            "name": course.name,
          };
        }
        return e;
      }).toList();

      await prefs.setString('courses', jsonEncode(list));

      return true;
    } catch (e) {
      return false;
    }
  }
}