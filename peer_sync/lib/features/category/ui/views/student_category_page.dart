import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/features/category/ui/widgets/category_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';

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
  final evaluationController = Get.find<EvaluationController>();

  @override
  void initState() {
    super.initState();
    controller.loadCategoriesByStudent(widget.courseId);
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
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
        ),
        title: Text(
          widget.courseTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications_none,
              size: 30,
              color: isLight ? AppTheme.primaryColor : AppTheme.darkTextPrimary,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Text(
                "Categorías de Grupos",
                style: AppTheme.bodyM.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLight
                      ? AppTheme.primaryColor300
                      : AppTheme.darkTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Renderizamos las categorías
            ...controller.categories.map((item) {
              final subtitle = evaluationController.getActiveActivitySubtitle(
                item.id,
              );

              return Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => StudentActivitiesPage(
                            categoryId: item.id,
                            categoryName: item.name,
                          ),
                        );
                      },
                      child: ProjectCategoryCard(
                        title: item.name,
                        subtitle: subtitle,
                        leadingIcon: Icons.group,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            }),
          ],
        );
      }),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
