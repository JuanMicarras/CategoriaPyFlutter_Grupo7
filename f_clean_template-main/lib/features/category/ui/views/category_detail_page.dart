import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/loading_overlay.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/widgets/create_activity_modal.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadTeacherActivities(widget.categoryId);
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
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                    await controller.loadTeacherActivities(widget.categoryId);
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

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      if (priorityA == 0) {
        return a.endDate.compareTo(b.endDate);
      }

      if (priorityA == 1) {
        return a.startDate.compareTo(b.startDate);
      }

      return b.endDate.compareTo(a.endDate);
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openCreateActivityModal(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingTeacherActivities.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.teacherActivities.isEmpty) {
          return const Center(
            child: Text(
              "No hay actividades creadas aún.\nToca el botón '+' para comenzar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        final sortedActivities = _sortedTeacherActivities(
          controller.teacherActivities,
        );

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedActivities.length,
          itemBuilder: (context, index) {
            final activity = sortedActivities[index];
            final uiData = controller.getTeacherActivityUIData(activity);

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
        );
      }),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
