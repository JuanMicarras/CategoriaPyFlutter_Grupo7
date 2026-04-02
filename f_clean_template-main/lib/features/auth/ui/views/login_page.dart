import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

import '../../../../core/widgets/auth_logo.dart';
import '../../../../core/widgets/auth_input_container.dart';
import '../../../../core/widgets//auth_text_field.dart';

class LoginPage extends GetView<AuthController> {
  LoginPage({Key? key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      authController.clearErrors();
      authController.passwordController.text = 'ThePassword!1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthLogo(),
              const SizedBox(height: 20),

              Text(
                "Inicia Sesión",
                style: AppTheme.h1.copyWith(color: AppTheme.textColor),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿No tienes una cuenta? ",
                    style: TextStyle(color: Color(0xFF8A8E97)),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/signup'),
                    child: const Text(
                      "Regístrate",
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              AuthInputContainer(
                children: [
                  AuthTextField(
                    hint: "pepitojm@uninorte.edu.co",
                    icon: Icons.email_outlined,
                    isEmail: true,
                    controllerText: controller.emailController,
                    errorText: controller.emailError.value,
                  ),
                  const Divider(height: 1, color: Colors.black38),
                  AuthTextField(
                    hint: "*******",
                    readOnly: false,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controllerText: controller.passwordController,
                    errorText: controller.passwordError.value,
                  ),
                ],
              ),

              Obx(() {
                final error =
                    controller.emailError.value ??
                    controller.passwordError.value;
                if (error == null || error.isEmpty)
                  return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: Color.fromARGB(137, 21, 20, 20)),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: AppTheme.primaryColor
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed:
                        controller.isLoading.value ||
                            controller.emailError.value != null ||
                            controller.passwordError.value != null
                        ? null
                        : () {
                            controller.login(
                              controller.emailController.text.trim(),
                              controller.passwordController.text.trim(),
                            );
                          },
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
