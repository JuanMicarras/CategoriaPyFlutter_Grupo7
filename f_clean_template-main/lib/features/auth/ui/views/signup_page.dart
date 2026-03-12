import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

import '../../../../core/widgets/auth_logo.dart';
import '../../../../core/widgets/auth_input_container.dart';
import '../../../../core/widgets//auth_text_field.dart';

class SignUpPage extends GetView<AuthController> {
  SignUpPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthLogo(),
              const SizedBox(height: 20),

              const Text(
                "Crear cuenta",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A3F),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿Ya tienes una cuenta? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      "Inicia sesión",
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
                    hint: "Nombre completo",
                    icon: Icons.person_outline,
                    controllerText: controller.signUpNameController,
                  ),
                  const Divider(height: 1, color: Colors.black38),
                  AuthTextField(
                    hint: "Correo electrónico",
                    icon: Icons.email_outlined,
                    controllerText: controller.signUpEmailController,
                  ),
                  const Divider(height: 1, color: Colors.black38),
                  AuthTextField(
                    hint: "Contraseña",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controllerText: controller.signUpPasswordController,
                  ),
                ],
              ),

              const SizedBox(height: 40),

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
                            controller.signUp(
                              emailController.text,
                              passwordController.text,
                              'student',
                            );
                          },
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Registrarse",
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
