import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/category_card.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';

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
  final controller = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();

    /// 🔥 MISMA LÓGICA QUE TEACHER
    controller.loadCategories(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
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

      /// 🔥 DINÁMICO DESDE BD
      body: Obx(() {
        final categories = controller.categories;

        /// ⏳ LOADING
        if (controller.isLoading.value && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

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

            /// 🔥 LISTA DINÁMICA
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