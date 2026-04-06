import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

import '../widgets/auth_logo.dart';
import '../widgets/auth_input_container.dart';
import '../widgets/auth_text_field.dart';

class SignUpPage extends GetView<AuthController> {
  SignUpPage({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().clearErrors();
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

              Text("Crear cuenta", style: AppTheme.h1.copyWith(color: AppTheme.textColor)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Get.toNamed('/login'),
                    child: const Text("Inicia sesión", style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
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
                    isEmail: true,
                    controllerText: controller.signUpEmailController,
                    errorText: controller.emailError.value,
                  ),
                  const Divider(height: 1, color: Colors.black38),
                  AuthTextField(
                    hint: "Contraseña",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controllerText: controller.signUpPasswordController,
                    errorText: controller.passwordError.value,
                  ),
                ],
              ),

              Obx(() {
                final error = controller.emailError.value ?? controller.passwordError.value;
                if (error == null || error.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: Text(
                    error,
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              }),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    // ¡Limpio!
                    onPressed: controller.canSubmitSignUp
                        ? () => controller.signUp(
                              controller.signUpEmailController.text.trim(),
                              controller.signUpPasswordController.text.trim(),
                              controller.signUpNameController.text.trim(),
                            )
                        : null,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Registrarse",
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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