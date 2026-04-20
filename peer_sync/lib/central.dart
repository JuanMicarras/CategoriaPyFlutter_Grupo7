import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/student/ui/views/student_home_page.dart';
import 'package:peer_sync/features/teacher/ui/views/teacher_home_page.dart';

import 'features/auth/ui/viewmodels/auth_controller.dart';
import 'features/auth/ui/views/login_page.dart';


class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authenticationController = Get.find<AuthController>();

    return Obx(() {
      // 1. Si no está logueado, lo mandamos al Login
      if (!authenticationController.isLogged) {
        return LoginPage();
      }

      // 2. Si está logueado, revisamos su rol
      if (authenticationController.user?.role == 'teacher') {
        return const  TeacherHomePage();
      }

      // 3. Si no es profesor (es estudiante), lo mandamos a su vista principal
      return const StudentHomePage();
    });
  }
}
