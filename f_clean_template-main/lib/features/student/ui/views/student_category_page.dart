import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/category_card.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/bindings/category_binding.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/bindings/course_binding.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/evaluation/ui/viewmodels/evaluation_controller.dart';
import 'package:peer_sync/features/evaluation/ui/views/student_activities_page.dart';
import 'package:peer_sync/features/student/ui/views/student_courses_page.dart';
import 'package:peer_sync/features/student/ui/views/student_home_page.dart';
import 'package:peer_sync/features/student/ui/views/student_profile_page.dart';

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

  void _ensureStudentCourseDependencies() {
    if (!Get.isRegistered<dynamic>(tag: 'student_courses_binding_marker')) {
      CourseBinding().dependencies();
      CategoryBinding().dependencies();
      Get.put<Object>(Object(), tag: 'student_courses_binding_marker');
    } else {
      if (!Get.isRegistered<CourseController>()) {
        CourseBinding().dependencies();
      }
      if (!Get.isRegistered<CategoryController>()) {
        CategoryBinding().dependencies();
      }
    }
  }

  void _handleNavTap(int index) {
    _ensureStudentCourseDependencies();

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const _StudentCoursesShell()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const _StudentHomeShell()),
        (route) => false,
      );
      return;
    }

    if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const _StudentProfileShell()),
        (route) => false,
      );
      return;
    }
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
      body: Obx(() {
        final categories = controller.categories;

        if (controller.isLoading.value && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        for (final category in categories) {
          if (!evaluationController.activeActivitiesCountByCategory.containsKey(
                category.id,
              ) &&
              !evaluationController.isLoadingActiveActivitiesCount(
                category.id,
              )) {
            evaluationController.loadActiveActivitiesCount(category.id);
          }
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
            ...categories.map((item) {
              final activeActivitiesCount = evaluationController
                  .getActiveActivitiesCount(item.id);

              final subtitle = activeActivitiesCount == 0
                  ? "Sin actividades activas"
                  : activeActivitiesCount == 1
                  ? "1 actividad activa"
                  : "$activeActivitiesCount actividades activas";

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
      bottomNavigationBar: NavBar(currentIndex: 0, onTap: _handleNavTap),
    );
  }
}

class _StudentCoursesShell extends StatelessWidget {
  const _StudentCoursesShell();

  void _ensureBindings() {
    if (!Get.isRegistered<dynamic>(tag: 'student_courses_binding_marker')) {
      CourseBinding().dependencies();
      CategoryBinding().dependencies();
      Get.put<Object>(Object(), tag: 'student_courses_binding_marker');
    } else {
      if (!Get.isRegistered<CourseController>()) {
        CourseBinding().dependencies();
      }
      if (!Get.isRegistered<CategoryController>()) {
        CategoryBinding().dependencies();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureBindings();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const StudentCoursesPage(),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const _StudentHomeShell()),
              (route) => false,
            );
          }
          if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const _StudentProfileShell()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

class _StudentHomeShell extends StatelessWidget {
  const _StudentHomeShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const StudentHomePage(),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const _StudentCoursesShell()),
              (route) => false,
            );
          }
          if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const _StudentProfileShell()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

class _StudentProfileShell extends StatelessWidget {
  const _StudentProfileShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const StudentProfilePage(),
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const _StudentCoursesShell()),
              (route) => false,
            );
          }
          if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const _StudentHomeShell()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
