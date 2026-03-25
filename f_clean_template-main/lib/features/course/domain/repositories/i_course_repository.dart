import 'package:peer_sync/features/course/domain/models/course.dart';

abstract class ICourseRepository {
  Future<void> joinCourse(String code, String email);
  Future<List<Course>> getCourses();
  Future<bool> createCourse(Course course);
  Future<bool> updateCourse(Course course);
}