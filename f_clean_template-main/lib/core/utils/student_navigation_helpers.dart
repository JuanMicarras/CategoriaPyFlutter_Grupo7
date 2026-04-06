import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/features/category/ui/bindings/category_binding.dart';
import 'package:peer_sync/features/category/ui/viewmodels/category_controller.dart';
import 'package:peer_sync/features/course/ui/bindings/course_binding.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/student/ui/views/student_courses_page.dart';
import 'package:peer_sync/features/student/ui/views/student_home_page.dart';
import 'package:peer_sync/features/student/ui/views/student_profile_page.dart';

class StudentNavigationHelpers {
  static void ensureStudentCourseDependencies() {
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

  static void handleNavTap(int index) {
    ensureStudentCourseDependencies();

    if (index == 0) {
      Get.offAll(() => const StudentCoursesShell());
    } else if (index == 1) {
      Get.offAll(() => const StudentHomeShell());
    } else if (index == 2) {
      Get.offAll(() => const StudentProfileShell());
    }
  }
}

// Sacamos las clases Shell de los archivos individuales y las hacemos públicas
class StudentCoursesShell extends StatelessWidget {
  const StudentCoursesShell({super.key});

  @override
  Widget build(BuildContext context) {
    StudentNavigationHelpers.ensureStudentCourseDependencies();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const StudentCoursesPage(),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) StudentNavigationHelpers.handleNavTap(index);
        },
      ),
    );
  }
}

class StudentHomeShell extends StatelessWidget {
  const StudentHomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const StudentHomePage(),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) StudentNavigationHelpers.handleNavTap(index);
        },
      ),
    );
  }
}

class StudentProfileShell extends StatelessWidget {
  const StudentProfileShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const StudentProfilePage(),
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) StudentNavigationHelpers.handleNavTap(index);
        },
      ),
    );
  }
}