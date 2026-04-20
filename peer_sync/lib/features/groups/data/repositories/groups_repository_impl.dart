import '../../domain/repositories/i_groups_repository.dart';
import '../datasources/remote/i_groups_remote_source.dart';

class GroupsRepositoryImpl implements IGroupsRepository {
  final IGroupsRemoteSource _dataSource;

  GroupsRepositoryImpl(this._dataSource);

  @override
  Future<void> importGroupsFromCsv(String courseId, String csvString) async {
    await _dataSource.importGroupsFromCsv(courseId, csvString);
  }
}