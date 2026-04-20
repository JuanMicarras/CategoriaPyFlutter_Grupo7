abstract class IGroupsRepository {
  Future<void> importGroupsFromCsv(String courseId, String csvString);
}