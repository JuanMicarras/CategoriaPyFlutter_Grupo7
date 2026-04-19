import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/teacher_report_page.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/analytics_card.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/criteria_bar_chart.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/metric_box.dart';
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
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
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

    if (isExpired) return "Vencida • $hour:$minute $amPm";
    if (isPending) return "Próximamente • $hour:$minute $amPm";
    return "Pendiente • $hour:$minute $amPm";
  }

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final categoryController = Get.find<CategoryController>();
    final evaluationController = Get.find<EvaluationController>();
    final analyticsController = Get.find<EvaluationAnalyticsController>();
    final notifController = Get.find<NotificationController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (courseController.courses.isEmpty &&
          evaluationController.homeActivities.isEmpty) {
        _loadHomeDataGlobal(
          courseController,
          categoryController,
          evaluationController,
        );
      }

      if (analyticsController.teacherHomeCompletionTrend.isEmpty &&
          !analyticsController.isLoadingTeacherHomeAnalytics.value) {
        analyticsController.loadTeacherHomeAnalytics();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        final recentCourses = courseController.courses.reversed
            .take(2)
            .toList();
        final recentActivities = evaluationController.homeActivities;
        final isLoading =
            courseController.isLoading.value ||
            evaluationController.isLoadingHomeActivities.value;
        final hasAnyContent =
            recentCourses.isNotEmpty || recentActivities.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            await _loadHomeDataGlobal(
              courseController,
              categoryController,
              evaluationController,
            );
            await analyticsController.loadTeacherHomeAnalytics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                      ),
                      Stack(
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => AnalyticsCard(
                      title: "Progreso del curso",
                      subtitle: "Completitud de actividades recientes",
                      chart:
                          analyticsController
                              .isLoadingTeacherHomeAnalytics
                              .value
                          ? const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : CriteriaBarChart(
                              data: analyticsController
                                  .teacherHomeCompletionTrend,
                              maxY: 50,
                              yInterval: 10,
                            ),
                      footer: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MetricBox(
                            title:
                                analyticsController
                                    .teacherActiveActivitiesMetric
                                    .value
                                    ?.title ??
                                'Activas',
                            value:
                                analyticsController
                                    .teacherActiveActivitiesMetric
                                    .value
                                    ?.value ??
                                '0',
                          ),
                          MetricBox(
                            title:
                                analyticsController
                                    .teacherPendingGroupsMetric
                                    .value
                                    ?.title ??
                                'Pendientes',
                            value:
                                analyticsController
                                    .teacherPendingGroupsMetric
                                    .value
                                    ?.value ??
                                '0',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isLoading && !hasAnyContent)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  if (!isLoading && !hasAnyContent)
                    const Center(
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

                  if (recentActivities.isNotEmpty) ...[
                    const Text(
                      "Actividades Agregadas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...recentActivities.map((activity) {
                      final now = DateTime.now();
                      final isExpired = now.isAfter(activity.endDate);
                      final fullStatus = _activityStatusText(activity);
                      final parts = fullStatus.split(' • ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityStatusCard(
                          title: activity.name,
                          month: _formatMonth(activity.endDate.month),
                          day: activity.endDate.day.toString(),
                          statusTag: parts.first,
                          statusDetail: parts.length > 1 ? parts.last : '',
                          dateBgColor: isExpired
                              ? Colors.grey[200]!
                              : const Color(0xFFE5DBF5),
                          dateTextColor: isExpired
                              ? Colors.grey[600]!
                              : const Color(0xFF8761BE),
                          onTap: () => Get.to(
                            () => TeacherReportPage(
                              activityId: activity.id,
                              activityName: activity.name,
                              categoryId: activity.categoryId,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                  ],

                  if (recentCourses.isNotEmpty) ...[
                    const Text(
                      "Cursos Agregados",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(recentCourses.length, (index) {
                        final course = recentCourses[index];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: (index == 0 && recentCourses.length > 1)
                                  ? 8
                                  : 0,
                              left: index == 1 ? 8 : 0,
                            ),
                            child: _HomeCourseCard(
                              title: course.name,
                              subtitle: categoryController.getCategoryCountText(
                                course.id,
                              ),
                              onTap: () => Get.to(
                                () => TeacherCourseDetailPage(
                                  courseId: course.id,
                                  courseTitle: course.name,
                                ),
                              ),
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
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}

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
              const SizedBox(height: 8),
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
                    Flexible(
                      child: Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9877C8),
                        ),
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
