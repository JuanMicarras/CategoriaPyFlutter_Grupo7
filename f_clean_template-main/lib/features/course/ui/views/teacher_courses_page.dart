import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/ui/views/student_category_page.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/ui/widgets/create_course_modal.dart';
import 'package:peer_sync/features/course/ui/widgets/course_card.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/features/category/ui/views/teacher_category_page.dart';

class TeacherCoursesPage extends StatelessWidget {
  const TeacherCoursesPage({super.key});

  void openCreateCourseModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final CourseController courseController = Get.find();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CreateCourseModal(
            nameController: nameController,
            onCancel: () => Get.back(),
            onCreate: () async {
              final name = nameController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("El nombre del curso es obligatorio"),
                  ),
                );
                return;
              }

              await courseController.createCourse(name);

              if (Get.isDialogOpen == true) {
                Get.back();
              }
            },
            onCsvSelected: (file) {
              print("CSV seleccionado: ${file?.name}");
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    final categoryController = Get.find<CategoryController>();
    final evaluationController = Get.find<EvaluationController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => openCreateCourseModal(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Text(
                      "Cursos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
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
                            icon: const Icon(
                              Icons.notifications_none,
                              size: 28,
                              color: Color(0xFF110E47),
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
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
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
                      "No has creado ningún curso",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: controller.courses.map((course) {
                    final previewCategories = categoryController
                        .getCategoriesPreview(course.id);

                    if (previewCategories.isEmpty) {
                      categoryController.loadCategoriesForCourseCard(course.id);
                    }

                    final visibleCategories = categoryController
                        .getCategoriesPreview(course.id)
                        .take(3);

                    final progressText = categoryController
                        .getCategoryCountText(course.id);

                    final projects = visibleCategories.map((c) {
                      return CourseProjectItem(
                        title: c.name,
                        subtitle: evaluationController
                            .getActiveActivitySubtitle(c.id),
                        onTap: (context, courseTitle, projectTitle) {
                          Get.to(
                            () => CourseDetailPage(
                              courseId: c.id,
                              courseTitle: c.name,
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
                            () => TeacherCourseDetailPage(
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
        currentIndex: 0,
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
