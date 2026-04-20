import 'package:peer_sync/features/evaluation/data/datasources/remote/i_evaluation_analytics_remote_source.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
import 'package:peer_sync/features/evaluation/domain/models/dashboard_metric.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_analytics_repository.dart';

class EvaluationAnalyticsRepositoryImpl
    implements IEvaluationAnalyticsRepository {
  final IEvaluationAnalyticsRemoteSource _remoteSource;

  EvaluationAnalyticsRepositoryImpl(this._remoteSource);

  @override
  Future<List<ChartPoint>> getStudentHomeTrend(String myEmail) async {
    return await _remoteSource.getStudentHomeTrend(myEmail);
  }

  @override
  Future<List<ChartPoint>> getStudentCategoryCriteriaAverages({
    required String categoryId,
    required String myEmail,
  }) async {
    return await _remoteSource.getStudentCategoryCriteriaAverages(
      categoryId: categoryId,
      myEmail: myEmail,
    );
  }

  @override
  Future<List<ChartPoint>> getTeacherHomeCompletionTrend() async {
    return await _remoteSource.getTeacherHomeCompletionTrend();
  }

  @override
  Future<List<ChartPoint>> getTeacherCategoryCriteriaAverages({
    required String categoryId,
  }) async {
    return await _remoteSource.getTeacherCategoryCriteriaAverages(
      categoryId: categoryId,
    );
  }

  @override
  Future<DashboardMetric> getStudentAverageMetric(String myEmail) async {
    return await _remoteSource.getStudentAverageMetric(myEmail);
  }

  @override
  Future<DashboardMetric> getStudentPendingMetric(String myEmail) async {
    return await _remoteSource.getStudentPendingMetric(myEmail);
  }

  @override
  Future<DashboardMetric> getTeacherActiveActivitiesMetric() async {
    return await _remoteSource.getTeacherActiveActivitiesMetric();
  }

  @override
  Future<DashboardMetric> getTeacherPendingGroupsMetric() async {
    return await _remoteSource.getTeacherPendingGroupsMetric();
  }
}
