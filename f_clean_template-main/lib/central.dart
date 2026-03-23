import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/ui/viewmodels/auth_controller.dart';
import 'features/auth/ui/views/login_page.dart';
import 'features/student/ui/views/home_page.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authenticationController = Get.find();

    return Obx(
      () => authenticationController.isLogged
          ? const HomePage()
          : const LoginPage(),
    );
  }
}
