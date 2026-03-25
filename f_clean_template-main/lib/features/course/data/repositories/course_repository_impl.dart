import '../../domain/repositories/i_course_repository.dart';
import '../datasources/remote/i_course_remote_source.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final ICourseRemoteSource _dataSource;

  CourseRepositoryImpl(this._dataSource);

  @override
  Future<void> joinCourse(String code, String email) async {
    await _dataSource.joinCourse(code, email);
  }
}