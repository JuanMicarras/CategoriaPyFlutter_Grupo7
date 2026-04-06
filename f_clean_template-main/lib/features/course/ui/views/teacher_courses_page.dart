import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/loading_overlay.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/features/course/ui/widgets/course_card.dart';
import 'package:peer_sync/features/course/ui/widgets/create_course_modal.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';
import '../../../category/ui/views/teacher_category_page.dart';

class TeacherCoursesPage extends StatelessWidget {
  const TeacherCoursesPage({super.key});

  void openNotifications() {
    print("Abrir notificaciones");
  }

  // Mudamos la función de crear curso aquí
  void openCreateCourseModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    dynamic selectedCsvFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CreateCourseModal(
              nameController: nameController,
              onCancel: () => Navigator.pop(context),
              onCreate: () async {
                final courseController = Get.find<CourseController>();
                final groupsController = Get.find<GroupsController>();

                final name = nameController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("El nombre del curso es obligatorio")),
                  );
                  return;
                }
                LoadingOverlay.show("Configurando curso y procesando estudiantes...");

                try {
                  final newCourseId = await courseController.createCourse(name);

                  if (newCourseId != null) {
                    if (selectedCsvFile != null && selectedCsvFile!.bytes != null) {
                      final csvString = utf8.decode(selectedCsvFile!.bytes!);
                      await groupsController.importCsvData(newCourseId, csvString);
                    }
                    LoadingOverlay.hide(); 
                    Navigator.pop(context); 
                  } else {
                    LoadingOverlay.hide();
                  }
                } catch (e) {
                  LoadingOverlay.hide();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Ocurrió un error inesperado: $e"), backgroundColor: Colors.red),
                  );
                }
              },
              onCsvSelected: (file) {
                selectedCsvFile = file;
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.find();
    final CategoryController categoryController = Get.find();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // Le damos su botón flotante
      floatingActionButton: FloatingActionButton(
        onPressed: () => openCreateCourseModal(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // El contenido va dentro del body
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
                    const Text("Cursos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.notifications_none, size: 28, color: Color(0xFF110E47)), onPressed: openNotifications),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator()));
                }
                if (controller.courses.isEmpty) {
                  return const Padding(padding: EdgeInsets.only(top: 40), child: Text("No hay cursos aún", style: TextStyle(color: Colors.grey)));
                }
                return Column(
                  children: controller.courses.map((course) {
                    final categories = categoryController.getCategoriesPreview(course.id);
                    if (categories.isEmpty) categoryController.loadCategoriesForCourseCard(course.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CourseCard(
                        title: course.name,
                        progressText: "0 de 0 actividades",
                        leadingIcon: Icons.phone_android,
                        projects: categories.take(3).map((c) => CourseProjectItem(title: c.name, subtitle: "Grupo")).toList(),
                        onTap: (context) {
                          // OJO: Si usas Get.to usa binding igual que con el estudiante, si usas Navigator está bien.
                          Get.to(() => CourseDetailPage(courseId: course.id, courseTitle: course.name));
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
      // Le agregamos el NavBar centralizado
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}