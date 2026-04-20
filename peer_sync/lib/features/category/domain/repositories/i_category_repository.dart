import '../models/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategoriesByCourse(String courseId);
  Future<List<Category>> getCategoriesByStudent(String courseId);
}