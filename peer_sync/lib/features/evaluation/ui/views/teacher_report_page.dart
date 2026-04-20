import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import '../viewmodels/teacher_report_controller.dart';

class TeacherReportPage extends StatefulWidget {
  final String activityId;
  final String activityName;
  final String categoryId;

  const TeacherReportPage({
    super.key,
    required this.activityId,
    required this.activityName,
    required this.categoryId,
  });

  @override
  State<TeacherReportPage> createState() => _TeacherReportPageState();
}

class _TeacherReportPageState extends State<TeacherReportPage> {
  final TeacherReportController controller =
      Get.find<TeacherReportController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadReport(widget.activityId, widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? const Color(0xFFF5F6FA)
          : AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: isLight
            ? const Color(0xFFF5F6FA)
            : AppTheme.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
        ),
        title: Text(
          'Reporte: ${widget.activityName}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.groupReports.isEmpty) {
          return const Center(child: Text("No hay grupos en esta categoría."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.groupReports.length,
          itemBuilder: (context, index) {
            final group = controller.groupReports[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isLight ? Colors.white : AppTheme.darkCard,
              child: ExpansionTile(
                shape: const Border(),
                title: Text(
                  group.groupName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isLight
                        ? AppTheme.primaryColor
                        : AppTheme.darkTextPrimary,
                  ),
                ),
                subtitle: Text(
                  "${group.students.length} estudiantes",
                  style: TextStyle(
                    color: isLight ? Colors.grey : AppTheme.darkTextMuted,
                  ),
                ),
                children: [
                  const Divider(),
                  ...group.students.map((student) {
                    final statusUI = controller.getStudentStatusUI(
                      student.isComplete,
                    );

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        controller.formatStudentName(
                          student.firstName,
                          student.lastName,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLight
                              ? Colors.black87
                              : AppTheme.darkTextPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isLight
                                  ? Colors.grey
                                  : AppTheme.darkTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusUI.bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusUI.text,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusUI.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            controller.formatGrade(student.finalGrade),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
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
