import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/loading_overlay.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/category/ui/views/student_category_page.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/course/ui/widgets/create_course_modal.dart';
import 'package:peer_sync/features/course/ui/widgets/course_card.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/features/category/ui/views/teacher_category_page.dart';

class TeacherCoursesPage extends StatelessWidget {
  const TeacherCoursesPage({super.key});

  void openCreateCourseModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    dynamic selectedCsvFile;

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
              final courseController = Get.find<CourseController>();
              final groupsController = Get.find<GroupsController>();

              final name = nameController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("El nombre del curso es obligatorio"),
                  ),
                );
                return;
              }
              LoadingOverlay.show(
                "Configurando curso y procesando estudiantes...",
              );

              try {
                final newCourseId = await courseController.createCourse(name);

                if (newCourseId != null) {
                  if (selectedCsvFile != null &&
                      selectedCsvFile!.bytes != null) {
                    final csvString = utf8.decode(selectedCsvFile!.bytes!);
                    await groupsController.importCsvData(
                      newCourseId,
                      csvString,
                    );
                  }
                  LoadingOverlay.hide();
                  Navigator.pop(context);
                } else {
                  LoadingOverlay.hide();
                }
              } catch (e) {
                LoadingOverlay.hide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Ocurrió un error inesperado: $e",
                      style: TextStyle(
                        color:
                            Theme.of(Get.context!).brightness ==
                                Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    backgroundColor:
                        Theme.of(Get.context!).brightness == Brightness.light
                        ? Color(0xFFD1B3FF)
                        : Color(0xFF3A3260),
                  ),
                );
              }
            },
            onCsvSelected: (file) {
              selectedCsvFile = file;
            },
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
        onPressed: () => openCreateCourseModal(context),
        backgroundColor: isLight
            ? AppTheme.secondaryColor
            : AppTheme.darkBorder,
        child: const Icon(Icons.add, color: Colors.white),
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
                      "No has creado ningún curso",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
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
