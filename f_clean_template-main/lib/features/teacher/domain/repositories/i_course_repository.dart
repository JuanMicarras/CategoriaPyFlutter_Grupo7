import 'package:peer_sync/features/teacher/domain/models/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();
  Future<bool> createCourse(Course course);
  Future<bool> updateCourse(Course course);
}
