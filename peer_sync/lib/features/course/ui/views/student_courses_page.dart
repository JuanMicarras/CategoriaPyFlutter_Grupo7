import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/course/ui/widgets/add_course_modal.dart';
import 'package:peer_sync/features/course/ui/widgets/course_card.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import '../../../category/ui/views/student_category_page.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  void openAddCourseModal(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final CourseController courseController = Get.find();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: AddCourseModal(
            codeController: codeController,
            onCancel: () => Get.back(),
            onAdd: () =>
                courseController.joinCourse(codeController.text.trim()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final CourseController controller = Get.find();
    final CategoryController categoryController = Get.find();
    final EvaluationController evaluationController = Get.find();

    return Scaffold(
      backgroundColor: isLight
          ? AppTheme.backgroundColor
          : AppTheme.darkBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddCourseModal(context),
        backgroundColor: isLight
            ? AppTheme.secondaryColor
            : AppTheme.darkBorder,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// HEADER CON NOTIFICACIONES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      "Cursos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLight
                            ? AppTheme.primaryColor
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      final notifController =
                          Get.find<NotificationController>();
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              size: 30,
                              color: isLight
                                  ? AppTheme.primaryColor
                                  : AppTheme.darkTextPrimary,
                            ),
                            onPressed: () =>
                                Get.to(() => const NotificationsPage()),
                          ),
                          if (notifController.unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(Get.context!).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF3A2A6B)
                                      : AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${notifController.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// LISTA DE CURSOS
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.courses.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "No estás inscrito en ningún curso",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: controller.courses.map((course) {
                    final previewCategories = categoryController
                        .getCategoriesPreview(course.id)
                        .take(3);

                    final progressText = categoryController
                        .getCategoryCountText(course.id);

                    final projects = previewCategories.map((c) {
                      return CourseProjectItem(
                        title: c.name,
                        subtitle: evaluationController
                            .getActiveActivitySubtitle(c.id),
                        onTap: (context, courseTitle, projectTitle) {
                          Get.to(
                            () => StudentActivitiesPage(
                              categoryId: c.id,
                              categoryName: c.name,
                            ),
                          );
                        },
                      );
                    }).toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CourseCard(
                        title: course.name,
                        progressText: progressText,
                        leadingIcon: Icons.school,
                        projects: projects,
                        onTap: (context) {
                          Get.to(
                            () => CourseDetailPage(
                              courseId: course.id,
                              courseTitle: course.name,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0, // 0 = Cursos
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
