import 'package:peer_sync/features/evaluation/domain/models/activity_report.dart';

abstract class IEvaluationRemoteSource {
  Future<void> createActivity(
    String categoryId,
    String name,
    String description,
    DateTime startDate,
    DateTime endDate,
    bool visibility,
  );
  Future<List<dynamic>> getActivitiesByCategory(String categoryId);
  Future<List<dynamic>> getPeers(String categoryId, String studentEmail);
  Future<List<dynamic>> getCriteria(String activityId);
  Future<Map<String, Map<String, double>>> getMyEvaluations(
    String activityId,
    String myEmail,
  );
  Future<void> submitEvaluation(
    String activityId,
    String categoryId,
    String evaluatorEmail,
    String evaluatedEmail,
    String comments,
    Map<String, double> scores,
  );
  Future<Map<String, double>> getMyAverageResults(
    String activityId,
    String myEmail,
  );
  
  Future<List<GroupReport>> getActivityReport(String activityId, String categoryId);
}
