import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/analytics_card.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/criteria_bar_chart.dart';

class StudentActivitiesPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const StudentActivitiesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  final EvaluationController controller = Get.find<EvaluationController>();
  final EvaluationAnalyticsController analyticsController =
      Get.find<EvaluationAnalyticsController>();

  Map<String, dynamic> _getGeneralTagData(double? generalValue) {
    if (generalValue == null || generalValue <= 0) {
      return {
        'label': 'Sin dato',
        'backgroundColor': const Color(0xFFE5E7EB),
        'textColor': const Color(0xFF6B7280),
      };
    }

    return {
      'label': generalValue.toStringAsFixed(1),
      'backgroundColor': const Color(0xFFEDE9FE),
      'textColor': const Color(0xFF7C3AED),
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadActivities(widget.categoryId);
      analyticsController.loadStudentCategoryAnalytics(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          'Actividades: ${widget.categoryName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: Obx(() {
        final chartData = analyticsController.studentCategoryCriteriaChart;
        final generalValue = CriteriaBarChart.extractGeneralValue(chartData);
        final tagData = _getGeneralTagData(generalValue);

        if (controller.isLoadingActivities.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = controller.sortedActivities;

        if (activities.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Obx(
                    () => AnalyticsCard(
                      title: "Rendimiento por criterio",
                      subtitle: "Tu promedio en esta categoría",
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: tagData['backgroundColor'] as Color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'General: ${tagData['label']}',
                            style: TextStyle(
                              color: tagData['textColor'] as Color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      chart:
                          analyticsController
                              .isLoadingStudentCategoryAnalytics
                              .value
                          ? const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : CriteriaBarChart(
                              data: chartData,
                              hideGeneralBar: true,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: Text('No hay actividades disponibles.')),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => AnalyticsCard(
                  title: "Rendimiento por criterio",
                  subtitle: "Tu promedio en esta categoría",
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: tagData['backgroundColor'] as Color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'General: ${tagData['label']}',
                        style: TextStyle(
                          color: tagData['textColor'] as Color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  chart:
                      analyticsController
                          .isLoadingStudentCategoryAnalytics
                          .value
                      ? const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : CriteriaBarChart(data: chartData, hideGeneralBar: true),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final uiData = controller.getActivityUIData(activity);

                  final dateBgColor = uiData.isExpired
                      ? Colors.grey[200]!
                      : const Color(0xFFE5DBF5);
                  final dateTextColor = uiData.isExpired
                      ? Colors.grey[600]!
                      : const Color(0xFF8761BE);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ActivityStatusCard(
                      title: activity.name,
                      month: uiData.month,
                      day: uiData.day,
                      statusTag: uiData.statusLabel,
                      statusDetail: uiData.statusDetail,
                      dateBgColor: dateBgColor,
                      dateTextColor: dateTextColor,
                      onTap: () {
                        if (uiData.isActive || uiData.isExpired) {
                          Get.to(
                            () => StudentEvaluationPage(
                              activityId: activity.id,
                              activityName: activity.name,
                              categoryId: widget.categoryId,
                              visibility: activity.visibility,
                              isExpired: uiData.isExpired,
                            ),
                          );
                        } else {
                          Get.snackbar(
                            'Paciencia',
                            'Esta actividad aún no comienza.',
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
