abstract class IGroupsRemoteSource {
  Future<void> importGroupsFromCsv(String courseId, String csvString);
}