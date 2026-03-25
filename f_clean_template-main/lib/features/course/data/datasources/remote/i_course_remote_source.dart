abstract class ICourseRemoteSource {
  Future<void> joinCourse(String code, String email);
  Future<List<Map<String, dynamic>>> getCourses();
  Future<Map<String, dynamic>> createCourse(String id, String name, int code);
  Future<void> updateCourse(String name, String id);
  Future<List<Map<String, dynamic>>> getCoursesByUser();
}