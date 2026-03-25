abstract class ICourseRepository {
  Future<void> joinCourse(String code, String email);
}