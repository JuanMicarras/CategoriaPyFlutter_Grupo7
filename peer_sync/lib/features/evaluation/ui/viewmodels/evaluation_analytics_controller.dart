import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';
import 'package:peer_sync/features/evaluation/domain/models/dashboard_metric.dart';
import 'package:peer_sync/features/evaluation/domain/repositories/i_evaluation_analytics_repository.dart';

class EvaluationAnalyticsController extends GetxController {
  final IEvaluationAnalyticsRepository repository;

  EvaluationAnalyticsController(this.repository);

  final studentHomeTrend = <ChartPoint>[].obs;
  final studentCategoryCriteriaChart = <ChartPoint>[].obs;
  final teacherHomeCompletionTrend = <ChartPoint>[].obs;
  final teacherCategoryCriteriaChart = <ChartPoint>[].obs;

  final studentAverageMetric = Rxn<DashboardMetric>();
  final studentPendingMetric = Rxn<DashboardMetric>();
  final teacherActiveActivitiesMetric = Rxn<DashboardMetric>();
  final teacherPendingGroupsMetric = Rxn<DashboardMetric>();

  final isLoadingStudentHomeAnalytics = false.obs;
  final isLoadingStudentCategoryAnalytics = false.obs;
  final isLoadingTeacherHomeAnalytics = false.obs;
  final isLoadingTeacherCategoryAnalytics = false.obs;

  Future<void> loadStudentHomeAnalytics() async {
    try {
      isLoadingStudentHomeAnalytics.value = true;

      final authController = Get.find<AuthController>();
      final myEmail = authController.user?.email ?? '';

      if (myEmail.isEmpty) {
        studentHomeTrend.clear();
        studentAverageMetric.value = null;
        studentPendingMetric.value = null;
        return;
      }

      final trend = await repository.getStudentHomeTrend(myEmail);
      final average = await repository.getStudentAverageMetric(myEmail);
      final pending = await repository.getStudentPendingMetric(myEmail);

      studentHomeTrend.assignAll(trend);
      studentAverageMetric.value = average;
      studentPendingMetric.value = pending;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las analíticas del estudiante: $e',
        backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
            ? const Color(0xFFD1B3FF)
            : const Color(0xFF3A3260),
        colorText: Colors.white,
      );
    } finally {
      isLoadingStudentHomeAnalytics.value = false;
    }
  }

  Future<void> loadStudentCategoryAnalytics(String categoryId) async {
    try {
      isLoadingStudentCategoryAnalytics.value = true;

      final authController = Get.find<AuthController>();
      final myEmail = authController.user?.email ?? '';

      if (myEmail.isEmpty) {
        studentCategoryCriteriaChart.clear();
        return;
      }

      final result = await repository.getStudentCategoryCriteriaAverages(
        categoryId: categoryId,
        myEmail: myEmail,
      );

      studentCategoryCriteriaChart.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la analítica de la categoría del estudiante: $e',
        backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
            ? const Color(0xFFD1B3FF)
            : const Color(0xFF3A3260),
        colorText: Colors.white,
      );
    } finally {
      isLoadingStudentCategoryAnalytics.value = false;
    }
  }

  Future<void> loadTeacherHomeAnalytics() async {
    try {
      isLoadingTeacherHomeAnalytics.value = true;

      final trend = await repository.getTeacherHomeCompletionTrend();
      final active = await repository.getTeacherActiveActivitiesMetric();
      final pending = await repository.getTeacherPendingGroupsMetric();

      teacherHomeCompletionTrend.assignAll(trend);
      teacherActiveActivitiesMetric.value = active;
      teacherPendingGroupsMetric.value = pending;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las analíticas del profesor: $e',
        backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
            ? const Color(0xFFD1B3FF)
            : const Color(0xFF3A3260),
        colorText: Colors.white,
      );
    } finally {
      isLoadingTeacherHomeAnalytics.value = false;
    }
  }

  Future<void> loadTeacherCategoryAnalytics(String categoryId) async {
    try {
      isLoadingTeacherCategoryAnalytics.value = true;

      final result = await repository.getTeacherCategoryCriteriaAverages(
        categoryId: categoryId,
      );

      teacherCategoryCriteriaChart.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la analítica de la categoría del profesor: $e',
        backgroundColor: Theme.of(Get.context!).brightness == Brightness.light
            ? const Color(0xFFD1B3FF)
            : const Color(0xFF3A3260),
        colorText: Colors.white,
      );
    } finally {
      isLoadingTeacherCategoryAnalytics.value = false;
    }
  }
}
