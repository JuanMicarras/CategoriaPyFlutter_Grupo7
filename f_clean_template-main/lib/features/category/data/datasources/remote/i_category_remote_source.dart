abstract class ICategoryRemoteSource {
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(String courseId);
}