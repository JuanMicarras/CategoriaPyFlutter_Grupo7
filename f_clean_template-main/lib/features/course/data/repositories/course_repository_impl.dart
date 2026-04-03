import 'package:peer_sync/features/course/domain/models/course.dart';
import 'package:peer_sync/features/course/domain/repositories/i_course_repository.dart';
import 'package:peer_sync/features/course/data/datasources/remote/i_course_remote_source.dart';
import 'package:peer_sync/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CourseRepositoryImpl implements ICourseRepository {
  final ICourseRemoteSource _dataSource;
  final IAuthRepository _authRepository;
 // 👈 NUEVO

  CourseRepositoryImpl(this._dataSource, this._authRepository);

  @override
  Future<void> joinCourse(String code, String email) async {
    await _authRepository.safeRequest(() {
      return _dataSource.joinCourse(code, email);
    });
  }

  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await _authRepository.safeRequest(() {
        return _dataSource.getCourses();
      });

      final courses = response.map<Course>((e) {
        return Course(id: e['id'], name: e['name'], code: e['code']);
      }).toList();

      /// 🔥 Guardar en cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('courses', jsonEncode(response));

      return courses;
    } catch (e) {
      /// 🔥 fallback local
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      if (stored == null) return [];

      final List decoded = jsonDecode(stored);

      return decoded.map<Course>((e) {
        return Course(id: e['id'], name: e['name'], code: e['code']);
      }).toList();
    }
  }

  @override
  Future<bool> createCourse(Course course) async {
    try {
      final response = await _authRepository.safeRequest(() {
        return _dataSource.createCourse(
          course.id,
          course.name,
          course.code,
        );
      });

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

  @override
  Future<bool> updateCourse(Course course) async {
    try {
      await _authRepository.safeRequest(() {
        return _dataSource.updateCourse(course.id, course.name);
      });

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('courses');

      if (stored == null) return true;

      List list = jsonDecode(stored);

      list = list.map((e) {
        if (e['id'] == course.id) {
          return {"id": course.id, "name": course.name};
        }
        return e;
      }).toList();

      await prefs.setString('courses', jsonEncode(list));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Course>> getCoursesByUser() async {
    final data = await _authRepository.safeRequest(() {
      return _dataSource.getCoursesByUser();
    });

    return data
        .map((e) => Course(id: e['id'], name: e['name'], code: e['code']))
        .toList();
  }
}
