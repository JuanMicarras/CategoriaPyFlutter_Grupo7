import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/remote/i_category_remote_source.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final ICategoryRemoteSource remote;

  CategoryRepositoryImpl(this.remote);

  @override
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    final data = await remote.getCategoriesByCourse(courseId);

    return data
        .map((e) => Category(
              id: e["id"],
              name: e["name"],
              courseId: e["course_id"],
            ))
        .toList();
  }
}