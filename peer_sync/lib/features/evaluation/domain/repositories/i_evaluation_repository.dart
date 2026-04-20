import 'package:peer_sync/features/evaluation/domain/models/activity_report.dart';

import '../models/activity.dart';

abstract class IEvaluationRepository {
  // Recibimos los datos básicos para crear la actividad
  Future<void> createActivity({
    required String categoryId,
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required bool visibility,
  });

  Future<List<Activity>> getActivitiesByCategory(String categoryId);
  Future<List<dynamic>> getPeers(String categoryId, String studentEmail);
  Future<List<dynamic>> getCriteria(String activityId);
  Future<Map<String, Map<String, double>>> getMyEvaluations(String activityId, String myEmail);
  Future<void> submitEvaluation(String activityId, String categoryId, String evaluatorEmail, String evaluatedEmail, String comments, Map<String, double> scores);
  Future<Map<String, double>> getMyAverageResults(String activityId, String myEmail);
  Future<List<GroupReport>> getActivityReport(String activityId, String categoryId);
}