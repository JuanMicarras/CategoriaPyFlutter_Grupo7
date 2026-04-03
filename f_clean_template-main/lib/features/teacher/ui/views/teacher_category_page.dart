import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/category_card.dart';
import 'package:peer_sync/core/widgets/create_category_modal.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/groups/ui/viewmodels/groups_controller.dart';

import 'teacher_home_page.dart';
import 'teacher_profile_page.dart';

// 🔥 IMPORTAR COURSE CONTROLLER
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final categoryController = Get.find<CategoryController>();
  final groupsController = Get.find<GroupsController>();
  final courseController = Get.find<CourseController>();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    categoryController.loadCategories(widget.courseId);
  }

  void openCreateCategoryModal(BuildContext context) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CreateGroupCategoryModal(
            onCancel: () {
              if (!groupsController.isLoading.value) {
                Get.back();
              }
            },
            onCreate: () {
              Get.back();
            },
            onCsvSelected: (file) async {
              if (file != null && file.bytes != null) {
                final csvString = utf8.decode(file.bytes!);

                Get.back();

                await groupsController.importCsvData(
                  widget.courseId,
                  csvString,
                );
                await categoryController.loadCategories(widget.courseId);
              } else {
                Get.snackbar(
                  'Error',
                  'No se pudo leer el archivo seleccionado',
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildCourseDetail(),
      const TeacherHomePage(),
      const TeacherProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      backgroundColor: const Color(0xFFF5F6FA),

      floatingActionButton: currentIndex == 0
          ? Obx(
              () => groupsController.isLoading.value
                  ? const CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: () {
                        openCreateCategoryModal(context);
                      },
                      backgroundColor: AppTheme.secondaryColor,
                      child: const Icon(Icons.add),
                    ),
            )
          : null,

      bottomNavigationBar: NavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCourseDetail() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: Obx(() {
        final categories = categoryController.categories;

        if (categoryController.isLoading.value && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// 🔥 TÍTULO DEL CÓDIGO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Text(
                "Código del curso",
                style: AppTheme.bodyM.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor300,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔥 CARD DEL CÓDIGO
            Center(
              child: Obx(() {
                final code =
                    courseController.getCodeById(widget.courseId);

                if (code == null) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        code.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: code.toString()),
                          );

                          Get.snackbar(
                            "Copiado",
                            "Código copiado al portapapeles",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.copy,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            /// 🔥 CATEGORÍAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Text(
                "Categorias de Grupos",
                style: AppTheme.bodyM.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor300,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ...categories.map((item) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ProjectCategoryCard(
                      title: item.name,
                      subtitle: "Grupo",
                      leadingIcon: Icons.group,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            }).toList(),
          ],
        );
      }),
    );
  }
}
