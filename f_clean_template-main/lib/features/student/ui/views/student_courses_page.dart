import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/course_card.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'student_category_page.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  void openNotifications() {
    print("Abrir notificaciones");
    Get.to(() => const NotificationsPage());
  }

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find();
    final CategoryController categoryController = Get.find();
    final EvaluationController evaluationController =
        Get.find<EvaluationController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
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
                        // Asegúrate de tener importado tu NotificationController arriba en el archivo
                        final notifController =
                            Get.find<NotificationController>();

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                size: 28, // Mantenemos tu tamaño original
                                color: Color(
                                  0xFF110E47,
                                ), // Mantenemos tu color original
                              ),
                              // Aquí puedes dejar openNotifications o usar el Get.to() que te pasaron
                              onPressed: openNotifications,
                            ),

                            // La burbuja roja solo aparece si hay más de 0 notificaciones
                            if (notifController.unreadCount > 0)
                              Positioned(
                                right:
                                    8, // Lo ajusté un poco para que cuadre con tu ícono tamaño 28
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
                    "No estás inscrito en ningún curso",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: controller.courses.map((course) {
                  final categories = categoryController.getCategoriesPreview(
                    course.id,
                  );

                  if (categories.isEmpty) {
                    categoryController.loadCategoriesForCourseCardByStudent(
                      course.id,
                    );
                  }

                  for (final category in categories.take(3)) {
                    if (!evaluationController.activeActivitiesCountByCategory
                            .containsKey(category.id) &&
                        !evaluationController.isLoadingActiveActivitiesCount(
                          category.id,
                        )) {
                      evaluationController.loadActiveActivitiesCount(
                        category.id,
                      );
                    }
                  }

                  final categoriesCount = categories.length;
                  final progressText = categoriesCount == 0
                      ? "Sin categorías"
                      : categoriesCount == 1
                      ? "1 categoría"
                      : "$categoriesCount categorías";

                  final projects = categories.take(3).map((c) {
                    final activeActivitiesCount = evaluationController
                        .getActiveActivitiesCount(c.id);

                    final subtitle = activeActivitiesCount == 0
                        ? "Sin actividades activas"
                        : activeActivitiesCount == 1
                        ? "1 actividad activa"
                        : "$activeActivitiesCount actividades activas";

                    return CourseProjectItem(
                      title: c.name,
                      subtitle: subtitle,
                      onTap: (context, courseTitle, projectTitle) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentActivitiesPage(
                              categoryId: c.id,
                              categoryName: c.name,
                            ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailPage(
                              courseId: course.id,
                              courseTitle: course.name,
                            ),
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
    );
  }
}
