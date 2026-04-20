import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
import 'package:peer_sync/features/evaluation/domain/models/dashboard_metric.dart';

abstract class IEvaluationAnalyticsRepository {
  Future<List<ChartPoint>> getStudentHomeTrend(String myEmail);

  Future<List<ChartPoint>> getStudentCategoryCriteriaAverages({
    required String categoryId,
    required String myEmail,
  });

  Future<List<ChartPoint>> getTeacherHomeCompletionTrend();

  Future<List<ChartPoint>> getTeacherCategoryCriteriaAverages({
    required String categoryId,
  });

  Future<DashboardMetric> getStudentAverageMetric(String myEmail);

  Future<DashboardMetric> getStudentPendingMetric(String myEmail);

  Future<DashboardMetric> getTeacherActiveActivitiesMetric();

  Future<DashboardMetric> getTeacherPendingGroupsMetric();
}
