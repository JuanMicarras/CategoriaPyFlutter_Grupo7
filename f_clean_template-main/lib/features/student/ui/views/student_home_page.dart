import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/graph.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/domain/models/activity.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_evaluation_page.dart';
import 'package:peer_sync/features/notifications/ui/viewmodels/notification_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/features/student/ui/views/student_category_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final CourseController courseController = Get.find<CourseController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final EvaluationController evaluationController =
      Get.find<EvaluationController>();

  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    if (_didInitialLoad) return;
    _didInitialLoad = true;

    await courseController.loadCoursesByUser();

    for (final course in courseController.courses) {
      await categoryController.loadCategoriesForCourseCardByStudent(course.id);
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

  void openNotifications() {
    Get.to(() => const NotificationsPage());
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
    final timeText = "$hour:$minute $amPm";

    if (isExpired) return "Vencida • $timeText";
    if (isPending) return "Próximamente • $timeText";
    return "Pendiente • $timeText";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recentCourses = courseController.courses.reversed.take(2).toList();
      final recentActivities = evaluationController.homeActivities;

      final isLoading =
          courseController.isLoading.value ||
          evaluationController.isLoadingHomeActivities.value;

      final hasAnyContent =
          recentCourses.isNotEmpty || recentActivities.isNotEmpty;

      return RefreshIndicator(
        onRefresh: () async {
          _didInitialLoad = false;
          await _loadHomeData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
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
                        // Asegúrate de tener importado tu NotificationController arriba en el archivo
                        final notifController =
                            Get.find<NotificationController>();

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                size: 28, // Mantenemos tu tamaño original
                                color: Color(
                                  0xFF110E47,
                                ), // Mantenemos tu color original
                              ),
                              // Aquí puedes dejar openNotifications o usar el Get.to() que te pasaron
                              onPressed: openNotifications,
                            ),

                            // La burbuja roja solo aparece si hay más de 0 notificaciones
                            if (notifController.unreadCount > 0)
                              Positioned(
                                right:
                                    8, // Lo ajusté un poco para que cuadre con tu ícono tamaño 28
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

                EvaluationCard(),

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
                  const _HomeSectionTitle(title: "Actividades Agregadas"),
                  const SizedBox(height: 20),
                  ...recentActivities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HomeActivityCard(
                        title: activity.name,
                        month: _formatMonth(activity.endDate.month),
                        day: activity.endDate.day.toString(),
                        subtitle: _activityStatusText(activity),
                        onTap: () {
                          final now = DateTime.now();
                          final isExpired = now.isAfter(activity.endDate);

                          Get.to(
                            () => StudentEvaluationPage(
                              activityId: activity.id,
                              activityName: activity.name,
                              categoryId: activity.categoryId,
                              isExpired: isExpired,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                if (recentCourses.isNotEmpty) ...[
                  const _HomeSectionTitle(title: "Cursos Agregados"),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(recentCourses.length, (index) {
                      final course = recentCourses[index];
                      final categories = categoryController
                          .getCategoriesPreview(course.id);
                      final categoriesCount = categories.length;

                      final subtitle = categoriesCount == 0
                          ? "Sin categorías"
                          : categoriesCount == 1
                          ? "1 categoría"
                          : "$categoriesCount categorías";

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
                            subtitle: subtitle,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseDetailPage(
                                    courseId: course.id,
                                    courseTitle: course.name,
                                  ),
                                ),
                              );
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
    });
  }
}

class _HomeSectionTitle extends StatelessWidget {
  final String title;

  const _HomeSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }
}

class _HomeActivityCard extends StatelessWidget {
  final String title;
  final String month;
  final String day;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeActivityCard({
    required this.title,
    required this.month,
    required this.day,
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
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5DBF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      month,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8761BE),
                      ),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8761BE),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyS.copyWith(
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
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
                spreadRadius: 0,
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
