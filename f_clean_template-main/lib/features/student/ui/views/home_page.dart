import 'package:flutter/material.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/add_course_modal.dart';
import 'package:peer_sync/features/course/ui/viewmodels/course_controller.dart';
import 'package:peer_sync/features/student/ui/views/student_profile_page.dart';
import 'student_home_page.dart';
import 'student_courses_page.dart';
import 'Profile_page.dart';
import 'package:get/get.dart';

class HomePageSt extends StatefulWidget {
  const HomePageSt({super.key});

  @override
  State<HomePageSt> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageSt> {
  int currentIndex = 1;

  final List<Widget> pages = const [
    StudentCoursesPage(),
    StudentHomePage(),
    StudentProfilePage(),
  ];

  void openAddCourseModal() {
    final TextEditingController codeController = TextEditingController();
    
    final CourseController courseController = Get.find();
    
    
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: AddCourseModal(
            codeController: codeController,
            onCancel: () {
              // Usamos navegación GetX para cerrar
              Get.back();
            },
            onAdd: () {
              courseController.joinCourse(codeController.text.trim());
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: openAddCourseModal,
              backgroundColor: AppTheme.secondaryColor,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
