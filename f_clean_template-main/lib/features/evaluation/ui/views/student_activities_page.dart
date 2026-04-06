import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadActivities(widget.categoryId);
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
        if (controller.isLoadingActivities.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final activities = controller.sortedActivities;
        if (activities.isEmpty) {
          return const Center(child: Text('No hay actividades disponibles.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            
            // 2. Le pedimos al controlador TODOS los datos listos para pintar
            final uiData = controller.getActivityUIData(activity);

            // Los colores siguen siendo puramente de la vista (UI)
            final dateBgColor = uiData.isExpired ? Colors.grey[200]! : const Color(0xFFE5DBF5);
            final dateTextColor = uiData.isExpired ? Colors.grey[600]! : const Color(0xFF8761BE);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ActivityStatusCard(
                title: activity.name,
                month: uiData.month,         // Sacado de uiData
                day: uiData.day,             // Sacado de uiData
                statusTag: uiData.statusLabel, // Sacado de uiData
                statusDetail: uiData.statusDetail, // Sacado de uiData
                dateBgColor: dateBgColor,
                dateTextColor: dateTextColor,
                onTap: () {
                  if (uiData.isActive || uiData.isExpired) {
                    Get.to(
                      () => StudentEvaluationPage(
                        activityId: activity.id,
                        activityName: activity.name,
                        categoryId: widget.categoryId,
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
        );
      }),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}