import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/activity_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_analytics_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/analytics_card.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/metric_box.dart';
import 'package:peer_sync/features/evaluation/ui/widgets/student_trend_chart.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/features/category/ui/views/student_category_page.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  Map<String, dynamic> _getAverageTagData(String? rawValue) {
    final average = double.tryParse(rawValue ?? '');

    if (average == null || average <= 0) {
      return {
        'label': 'Sin dato',
        'backgroundColor': const Color(0xFFE5E7EB),
        'textColor': const Color(0xFF6B7280),
      };
    }

    if (average >= 1.0 && average < 2.0) {
      return {
        'label': 'Deficiente',
        'backgroundColor': const Color(0xFFFEE2E2),
        'textColor': const Color(0xFFB91C1C),
      };
    }

    if (average >= 2.0 && average < 3.0) {
      return {
        'label': 'Regular',
        'backgroundColor': const Color(0xFFFEF3C7),
        'textColor': const Color(0xFFB45309),
      };
    }

    if (average >= 3.0 && average < 4.0) {
      return {
        'label': 'Bien',
        'backgroundColor': const Color(0xFFEDE9FE),
        'textColor': const Color(0xFF7C3AED),
      };
    }

    if (average >= 4.0 && average < 4.5) {
      return {
        'label': 'Muy Bien',
        'backgroundColor': const Color(0xFFDDD6FE),
        'textColor': const Color(0xFF6D28D9),
      };
    }

    return {
      'label': 'Excelente',
      'backgroundColor': const Color(0xFFDCFCE7),
      'textColor': const Color(0xFF15803D),
    };
  }

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();
    final CategoryController categoryController =
        Get.find<CategoryController>();
    final EvaluationController evaluationController =
        Get.find<EvaluationController>();
    final EvaluationAnalyticsController analyticsController =
        Get.find<EvaluationAnalyticsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (courseController.courses.isEmpty &&
          evaluationController.homeActivities.isEmpty) {
        evaluationController.loadHomeDataGlobal();
      }

      if (analyticsController.studentHomeTrend.isEmpty &&
          !analyticsController.isLoadingStudentHomeAnalytics.value) {
        analyticsController.loadStudentHomeAnalytics();
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

        final tagData = _getAverageTagData(
          analyticsController.studentAverageMetric.value?.value,
        );

        return RefreshIndicator(
          onRefresh: () async {
            await evaluationController.loadHomeDataGlobal();
            await analyticsController.loadStudentHomeAnalytics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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

                  Obx(
                    () => AnalyticsCard(
                      title: "Mis resultados",
                      subtitle: "Evolución reciente",
                      trailing: Padding(
                        padding: const EdgeInsets.only(right: 22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: tagData['backgroundColor'] as Color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Estado: ${tagData['label']}',
                            style: TextStyle(
                              color: tagData['textColor'] as Color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      chart:
                          analyticsController
                              .isLoadingStudentHomeAnalytics
                              .value
                          ? const SizedBox(
                              height: 180,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : StudentTrendChart(
                              data: analyticsController.studentHomeTrend,
                            ),
                      footer: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MetricBox(
                            title:
                                analyticsController
                                    .studentAverageMetric
                                    .value
                                    ?.title ??
                                'Promedio',
                            value:
                                analyticsController
                                    .studentAverageMetric
                                    .value
                                    ?.value ??
                                '0.0',
                          ),
                          MetricBox(
                            title:
                                analyticsController
                                    .studentPendingMetric
                                    .value
                                    ?.title ??
                                'Pendientes',
                            value:
                                analyticsController
                                    .studentPendingMetric
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
                    const Padding(
                      padding: EdgeInsets.only(top: 40, bottom: 40),
                      child: CircularProgressIndicator(),
                    ),

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
                      final uiData = evaluationController.getActivityUIData(
                        activity,
                      );
                      final dateBgColor = uiData.isExpired
                          ? Colors.grey[200]!
                          : const Color(0xFFE5DBF5);
                      final dateTextColor = uiData.isExpired
                          ? Colors.grey[600]!
                          : const Color(0xFF8761BE);

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
                            Get.to(
                              () => StudentEvaluationPage(
                                activityId: activity.id,
                                activityName: activity.name,
                                categoryId: activity.categoryId,
                                visibility: activity.visibility,
                                isExpired: uiData.isExpired,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                  ],

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(recentCourses.length, (index) {
                        final course = recentCourses[index];
                        final progressText = categoryController
                            .getCategoryCountText(course.id);

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 0 && recentCourses.length > 1
                                  ? 8
                                  : 0,
                              left: index == 1 ? 8 : 0,
                            ),
                            child: _HomeCourseCard(
                              title: course.name,
                              subtitle: progressText,
                              onTap: () => Get.to(
                                () => CourseDetailPage(
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
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
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
