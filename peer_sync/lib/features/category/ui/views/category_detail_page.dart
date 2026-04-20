import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/loading_overlay.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/widgets/create_activity_modal.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/analytics_card.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/criteria_bar_chart.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final EvaluationController controller = Get.find<EvaluationController>();
  final EvaluationAnalyticsController analyticsController =
      Get.find<EvaluationAnalyticsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTeacherActivities(widget.categoryId);
      analyticsController.loadTeacherCategoryAnalytics(widget.categoryId);
    });
  }

  void openCreateActivityModal(BuildContext context) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Obx(
            () => CreateActivityModal(
              nameController: controller.nameController,
              startDateController: controller.startDateController,
              endDateController: controller.endDateController,
              startTimeController: controller.startTimeController,
              endTimeController: controller.endTimeController,
              isPublic: controller.isVisible.value,
              onPublicChanged: (val) => controller.isVisible.value = val,
              onCancel: () => Get.back(),
              onCreate: () async {
                if (!controller.isLoading.value) {
                  LoadingOverlay.show("Guardando actividad...");
                  final success = await controller.saveActivity(
                    widget.categoryId,
                  );
                  LoadingOverlay.hide();

                  if (success) {
                    if (Get.isDialogOpen == true) Get.back();
                    await controller.loadTeacherActivities(widget.categoryId);
                    await analyticsController.loadTeacherCategoryAnalytics(
                      widget.categoryId,
                    );
                  }
                }
              },
              onTapStartDate: () => controller.pickStartDate(context),
              onTapEndDate: () => controller.pickEndDate(context),
              onTapStartTime: () => controller.pickStartTime(context),
              onTapEndTime: () => controller.pickEndTime(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Activity> _sortedTeacherActivities(List<Activity> activities) {
    final sorted = List<Activity>.from(activities);
    final now = DateTime.now();

    int priority(Activity activity) {
      final isExpired = now.isAfter(activity.endDate);
      final isUpcoming = now.isBefore(activity.startDate);
      final isOpen = !isExpired && !isUpcoming;

      if (isOpen) return 0;
      if (isUpcoming) return 1;
      return 2;
    }

    sorted.sort((a, b) {
      final priorityA = priority(a);
      final priorityB = priority(b);

      if (priorityA != priorityB) return priorityA.compareTo(priorityB);

      if (priorityA == 0) return a.endDate.compareTo(b.endDate);
      if (priorityA == 1) return a.startDate.compareTo(b.startDate);
      return b.endDate.compareTo(a.endDate);
    });

    return sorted;
  }

  Map<String, dynamic> _getGeneralTagData(double? generalValue) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (generalValue == null || generalValue <= 0) {
      return {
        'label': 'Sin dato',
        'backgroundColor': isLight
            ? const Color(0xFFE5E7EB)
            : AppTheme.darkSurface,
        'textColor': isLight ? const Color(0xFF6B7280) : AppTheme.darkTextMuted,
      };
    }

    return {
      'label': generalValue.toStringAsFixed(1),
      'backgroundColor': isLight
          ? const Color(0xFFEDE9FE)
          : const Color(0xFF3F2A6B),
      'textColor': isLight ? const Color(0xFF7C3AED) : const Color(0xFFD1C4FF),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? const Color(0xFFF5F6FA)
          : AppTheme.darkBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => openCreateActivityModal(context),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme.secondaryColor
            : AppTheme.darkBorder,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: isLight
            ? const Color(0xFFF5F6FA)
            : AppTheme.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
          ),
        ),
      ),
      body: Obx(() {
        final chartData = analyticsController.teacherCategoryCriteriaChart;
        final generalValue = CriteriaBarChart.extractGeneralValue(chartData);
        final tagData = _getGeneralTagData(generalValue);

        if (controller.isLoadingTeacherActivities.value &&
            analyticsController.isLoadingTeacherCategoryAnalytics.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final sortedActivities = _sortedTeacherActivities(
          controller.teacherActivities,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => AnalyticsCard(
                  title: "Rendimiento por criterio",
                  subtitle: "Promedio del grupo en esta categoría",
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
                          .isLoadingTeacherCategoryAnalytics
                          .value
                      ? const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : CriteriaBarChart(data: chartData, hideGeneralBar: true),
                ),
              ),
            ),

            if (sortedActivities.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No hay actividades creadas aún.\nToca el botón '+' para comenzar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isLight ? Colors.black54 : AppTheme.darkTextMuted,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedActivities.length,
                  itemBuilder: (context, index) {
                    final activity = sortedActivities[index];
                    final uiData = controller.getTeacherActivityUIData(
                      activity,
                    );

                    final dateBgColor = uiData.isExpired
                        ? (isLight ? Colors.grey[200]! : AppTheme.darkSurface)
                        : (isLight
                              ? const Color(0xFFE5DBF5)
                              : const Color(0xFF3A2A6B));

                    final dateTextColor = uiData.isExpired
                        ? (isLight ? Colors.grey[600]! : AppTheme.darkTextMuted)
                        : (isLight
                              ? const Color(0xFF8761BE)
                              : const Color(0xFFD1C4FF));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ActivityStatusCard(
                        title: activity.name,
                        month: uiData.month,
                        day: uiData.day,
                        statusTag: uiData.statusTag,
                        statusDetail: uiData.statusDetail,
                        dateBgColor: dateBgColor,
                        dateTextColor: dateTextColor,
                        onTap: () {
                          Get.to(
                            () => TeacherReportPage(
                              activityId: activity.id,
                              activityName: activity.name,
                              categoryId: widget.categoryId,
                            ),
                          );
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
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
