import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

import '../../../../core/widgets/auth_logo.dart';
import '../../../../core/widgets/auth_input_container.dart';
import '../../../../core/widgets//auth_text_field.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({Key? key}) : super(key: key);

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
                    controllerText: controller.emailController,
                  ),
                  const Divider(height: 1, color: Colors.black38),
                  AuthTextField(
                    hint: "*******",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controllerText: controller.passwordController,
                  ),
                ],
              ),

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: controller.isLoading.value
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
