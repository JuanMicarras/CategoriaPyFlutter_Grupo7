import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/course_card.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'student_category_page.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  void openNotifications() {
    print("Abrir notificaciones");
  }

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find();

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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Color(0xFF110E47),
                    ),
                    onPressed: openNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 LISTA DINÁMICA
            Obx(() {
              /// ⏳ LOADING
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              /// 📭 VACÍO
              if (controller.courses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No estás inscrito en ningún curso",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              /// ✅ LISTA
              return Column(
                children: controller.courses.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CourseCard(
                      title: course.name,
                      progressText: "0 de 0 actividades",
                      progress: 0.0,
                      leadingIcon: Icons.school,
                      projects: const [],

                      onTap: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailPage(
                              courseTitle: course.name,
                              categories: const [],
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
