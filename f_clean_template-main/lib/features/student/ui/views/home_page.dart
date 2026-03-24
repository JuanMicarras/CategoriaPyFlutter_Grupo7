import 'package:flutter/material.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/core/widgets/add_course_modal.dart';
import 'package:peer_sync/features/student/ui/views/student_profile_page.dart';
import 'student_home_page.dart';
import 'student_courses_page.dart';
import 'Profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1;

  final List<Widget> pages = const [
    StudentCoursesPage(),
    StudentHomePage(),
    StudentProfilePage(),
  ];

  void openCreateCourseModal() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: AddCourseModal(
              codeController: codeController,
              onCancel: () {
                Navigator.pop(context);
              },
              onAdd: () {
                print("Código ingresado: ${codeController.text}");
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: openCreateCourseModal,
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
