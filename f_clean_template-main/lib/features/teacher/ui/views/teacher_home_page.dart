import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/graph.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/features/category/ui/views/teacher_category_page.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  Future<void> _loadHomeDataGlobal(
    CourseController courseController,
    CategoryController categoryController,
    EvaluationController evaluationController,
  ) async {
    await courseController.loadCoursesByUser();

    for (final course in courseController.courses) {
      await categoryController.loadCategoriesForCourseCard(course.id);
    }

    final categoryIds = <String>[];

    for (final course in courseController.courses) {
      final categories = categoryController.getCategoriesPreview(course.id);
      for (final category in categories) {
        categoryIds.add(category.id);
      }
    }

    await evaluationController.loadHomeActivitiesPreview(categoryIds);
  }

  String _formatMonth(int month) {
    const monthNames = [
      'ENE','FEB','MAR','ABR','MAY','JUN',
      'JUL','AGO','SEP','OCT','NOV','DIC',
    ];
    return monthNames[month - 1];
  }

  String _activityStatusText(Activity activity) {
    final now = DateTime.now();
    final isExpired = now.isAfter(activity.endDate);
    final isPending = now.isBefore(activity.startDate);

    final relevantDate = isPending ? activity.startDate : activity.endDate;

    final hour = relevantDate.hour > 12
        ? relevantDate.hour - 12
        : (relevantDate.hour == 0 ? 12 : relevantDate.hour);
    final amPm = relevantDate.hour >= 12 ? 'PM' : 'AM';
    final minute = relevantDate.minute.toString().padLeft(2, '0');
    final timeText = "$hour:$minute $amPm";

    if (isExpired) return "Vencida • $timeText";
    if (isPending) return "Próximamente • $timeText";
    return "Pendiente • $timeText";
  }

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final categoryController = Get.find<CategoryController>();
    final evaluationController = Get.find<EvaluationController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (courseController.courses.isEmpty &&
          evaluationController.homeActivities.isEmpty) {
        _loadHomeDataGlobal(
          courseController,
          categoryController,
          evaluationController,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        final recentCourses =
            courseController.courses.reversed.take(2).toList();
        final recentActivities = evaluationController.homeActivities;

        final isLoading =
            courseController.isLoading.value ||
            evaluationController.isLoadingHomeActivities.value;

        final hasAnyContent =
            recentCourses.isNotEmpty || recentActivities.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => _loadHomeDataGlobal(
            courseController,
            categoryController,
            evaluationController,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              "Contenido Reciente",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        /// NOTIFICACIONES
                        Obx(() {
                          final notifController =
                              Get.find<NotificationController>();

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none,
                                  size: 28,
                                  color: Color(0xFF110E47),
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
                  const EvaluationCard(),
                  const SizedBox(height: 20),

                  /// LOADING
                  if (isLoading && !hasAnyContent)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),

                  /// VACÍO
                  if (!isLoading && !hasAnyContent)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: const Center(
                        child: Text(
                          "Actualmente no hay nada para mostrar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ),

                  /// ACTIVIDADES
                  if (recentActivities.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Actividades Agregadas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ...recentActivities.map((activity) {
                      final now = DateTime.now();
                      final isExpired = now.isAfter(activity.endDate);

                      final dateBgColor = isExpired
                          ? Colors.grey[200]!
                          : const Color(0xFFE5DBF5);

                      final dateTextColor = isExpired
                          ? Colors.grey[600]!
                          : const Color(0xFF8761BE);

                      final fullStatus = _activityStatusText(activity);
                      final parts = fullStatus.split(' • ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityStatusCard(
                          title: activity.name,
                          month: _formatMonth(activity.endDate.month),
                          day: activity.endDate.day.toString(),
                          statusTag: parts.first,
                          statusDetail:
                              parts.length > 1 ? parts.last : '',
                          dateBgColor: dateBgColor,
                          dateTextColor: dateTextColor,
                          onTap: () {
                            Get.to(() => TeacherReportPage(
                                  activityId: activity.id,
                                  activityName: activity.name,
                                  categoryId: activity.categoryId,
                                ));
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 30),
                  ],

                  /// CURSOS
                  if (recentCourses.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cursos Agregados",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: List.generate(recentCourses.length, (index) {
                        final course = recentCourses[index];
                        final progressText = categoryController
                            .getCategoryCountText(course.id);

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 0 &&
                                      recentCourses.length > 1
                                  ? 8
                                  : 0,
                              left: index == 1 ? 8 : 0,
                            ),
                            child: _HomeCourseCard(
                              title: course.name,
                              subtitle: progressText,
                              onTap: () {
                                Get.to(() => TeacherCourseDetailPage(
                                      courseId: course.id,
                                      courseTitle: course.name,
                                    ));
                              },
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

      /// ✅ SOLO AQUÍ VA EL NAVBAR
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) =>
            TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}

/// CARD DE CURSO (CORREGIDA)
class _HomeCourseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCourseCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5DBF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  size: 20,
                  color: Color(0xFF9877C8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  "Contenido reciente del curso",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyS.copyWith(
                    color: const Color(0xFF718096),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE5F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people,
                      size: 14,
                      color: Color(0xFF9877C8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9877C8),
                      ),
                    ),
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
