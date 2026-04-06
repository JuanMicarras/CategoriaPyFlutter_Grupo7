import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/course/ui/widgets/course_card.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import '../../../category/ui/views/teacher_category_page.dart';

class TeacherCoursesPage extends StatelessWidget {
  const TeacherCoursesPage({super.key});

  void openNotifications() {
    Get.to(() => const NotificationsPage());
  }

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find();
    final CategoryController categoryController = Get.find();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔹 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Text(
                    "Cursos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28, color: Color(0xFF110E47)),
                    onPressed: openNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator()),
                );
              }
              if (controller.courses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("No hay cursos aún", style: TextStyle(color: Colors.grey)),
                );
              }

              return Column(
                children: controller.courses.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CourseCard(
                      title: course.name,
                      progressText: "0 de 0 actividades",
                      leadingIcon: Icons.phone_android,

                      /// 1. La UI solo pide la lista de "proyectos" ya procesada
                      projects: categoryController.getCourseProjectItems(course.id),

                      /// 2. Navegación limpia con GetX
                      onTap: (context) {
                        Get.to(() => CourseDetailPage(
                          courseId: course.id,
                          courseTitle: course.name,
                        ));
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