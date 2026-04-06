import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';

import 'package:peer_sync/core/widgets/graph.dart';
import 'package:peer_sync/core/widgets/navbar.dart'; 
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/features/category/ui/views/student_category_page.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();
    final CategoryController categoryController = Get.find<CategoryController>();
    final EvaluationController evaluationController = Get.find<EvaluationController>();

    // Cargamos los datos al construir la vista si están vacíos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (courseController.courses.isEmpty && evaluationController.homeActivities.isEmpty) {
        evaluationController.loadHomeDataGlobal();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        final recentCourses = courseController.courses.reversed.take(2).toList();
        final recentActivities = evaluationController.homeActivities;

        final isLoading = courseController.isLoading.value || evaluationController.isLoadingHomeActivities.value;
        final hasAnyContent = recentCourses.isNotEmpty || recentActivities.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => evaluationController.loadHomeDataGlobal(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20), // Ajustado el top para el SafeArea
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Home", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            Text("Contenido Reciente", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor)),
                          ],
                        ),
                        const Spacer(),
                        Obx(() {
                          final notifController = Get.find<NotificationController>();
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none, size: 28, color: Color(0xFF110E47)),
                                onPressed: () => Get.to(() => const NotificationsPage()),
                              ),
                              if (notifController.unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                    child: Text(
                                      '${notifController.unreadCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                  const EvaluationCard(),
                  const SizedBox(height: 20),

                  if (isLoading && !hasAnyContent)
                    const Padding(padding: EdgeInsets.only(top: 40, bottom: 40), child: CircularProgressIndicator()),

                  if (!isLoading && !hasAnyContent)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: const Center(
                        child: Text(
                          "Actualmente no hay nada para mostrar",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor),
                        ),
                      ),
                    ),

                  // ACTIVIDADES RECIENTES
                  if (recentActivities.isNotEmpty) ...[
                    const Align(alignment: Alignment.centerLeft, child: Text("Actividades Agregadas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor))),
                    const SizedBox(height: 20),
                    ...recentActivities.map((activity) {
                      
                      // ¡La magia! Le pedimos los datos formateados a nuestro controlador centralizado
                      final uiData = evaluationController.getActivityUIData(activity);
                      final dateBgColor = uiData.isExpired ? Colors.grey[200]! : const Color(0xFFE5DBF5);
                      final dateTextColor = uiData.isExpired ? Colors.grey[600]! : const Color(0xFF8761BE);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityStatusCard(
                          title: activity.name,
                          month: uiData.month,
                          day: uiData.day,
                          statusTag: uiData.statusLabel,
                          statusDetail: uiData.statusDetail,
                          dateBgColor: dateBgColor,
                          dateTextColor: dateTextColor,
                          onTap: () {
                            Get.to(() => StudentEvaluationPage(
                              activityId: activity.id,
                              activityName: activity.name,
                              categoryId: activity.categoryId,
                              isExpired: uiData.isExpired,
                            ));
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                  ],

                  // CURSOS AGREGADOS
                  if (recentCourses.isNotEmpty) ...[
                    const Align(alignment: Alignment.centerLeft, child: Text("Cursos Agregados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor))),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(recentCourses.length, (index) {
                        final course = recentCourses[index];
                        final progressText = categoryController.getCategoryCountText(course.id); // Reutilizamos nuestro helper

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 0 && recentCourses.length > 1 ? 8 : 0,
                              left: index == 1 ? 8 : 0,
                            ),
                            child: _HomeCourseCard(
                              title: course.name,
                              subtitle: progressText,
                              onTap: () => Get.to(() => CourseDetailPage(courseId: course.id, courseTitle: course.name)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
      // El NavBar limpio y estandarizado
      bottomNavigationBar: NavBar(
        currentIndex: 1, // 1 = Home
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
// Conservamos la tarjeta pequeña de cursos porque tiene proporciones específicas para el Grid del Home
class _HomeCourseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCourseCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 210,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x2E000000), offset: Offset(0, 2), blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Color(0xFFE5DBF5), shape: BoxShape.circle),
                child: const Icon(Icons.school, size: 20, color: Color(0xFF9877C8)),
              ),
              const SizedBox(height: 12),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTheme.bodyL.copyWith(fontWeight: FontWeight.w700, color: AppTheme.textColor)),
              const SizedBox(height: 6),
              Expanded(child: Text("Contenido reciente del curso", maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTheme.bodyS.copyWith(color: const Color(0xFF718096)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEBE5F7), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, size: 14, color: Color(0xFF9877C8)),
                    const SizedBox(width: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9877C8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}