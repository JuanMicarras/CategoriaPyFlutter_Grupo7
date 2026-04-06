import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart'; // Importante para la navegación limpia
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
    // Aquí inicia la orquestación limpia
    controller.loadCategoriesByStudent(widget.courseId);
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
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
                style: AppTheme.bodyM.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor300),
              ),
            ),
            const SizedBox(height: 20),
            
            // Renderizamos las categorías
            ...controller.categories.map((item) {
              
              // ¡Limpio! Le pedimos el texto ya formateado al controlador de evaluación
              final subtitle = evaluationController.getActiveActivitySubtitle(item.id);

              return Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => StudentActivitiesPage(
                          categoryId: item.id,
                          categoryName: item.name,
                        ));
                      },
                      child: ProjectCategoryCard(
                        title: item.name,
                        subtitle: subtitle, // Usamos el texto calculado
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
      // ¡Usamos el Helper unificado en lugar de repetir código!
      bottomNavigationBar: NavBar(
        currentIndex: 0, 
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index)
      ),
    );
  }
}