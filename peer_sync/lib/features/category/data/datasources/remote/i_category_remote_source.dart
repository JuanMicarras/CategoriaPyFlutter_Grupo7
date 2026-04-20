abstract class ICategoryRemoteSource {
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(String courseId);
  Future<List<Map<String, dynamic>>> getCategoriesByStudent(String courseId);
}