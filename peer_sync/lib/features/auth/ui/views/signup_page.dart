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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? AppTheme.backgroundColor
          : AppTheme.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthLogo(),
              const SizedBox(height: 20),

              Text(
                "Crear cuenta",
                style: AppTheme.h1.copyWith(
                  color: isLight
                      ? AppTheme.textColor
                      : AppTheme.darkTextPrimary,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Ya tienes una cuenta? ",
                    style: TextStyle(
                      color: isLight
                          ? const Color(0xFF8A8E97)
                          : const Color(0xFFB0B0B0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/login'),
                    child: Text(
                      "Inicia sesión",
                      style: TextStyle(
                        color: isLight
                            ? AppTheme.secondaryColor
                            : AppTheme.darkPrimarySoft,
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
                    errorText: controller.nameError.value, // ← Nuevo
                  ),
                  Divider(
                    height: 1,
                    color: isLight ? Colors.black38 : const Color(0xFF261C57),
                  ),
                  AuthTextField(
                    hint: "Correo electrónico",
                    icon: Icons.email_outlined,
                    isEmail: true,
                    controllerText: controller.signUpEmailController,
                    errorText: controller.emailError.value,
                  ),
                  Divider(
                    height: 1,
                    color: isLight ? Colors.black38 : const Color(0xFF261C57),
                  ),
                  AuthTextField(
                    hint: "Contraseña",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isLoginPassword: false,
                    controllerText: controller.signUpPasswordController,
                    errorText: controller.passwordError.value,
                  ),
                ],
              ),

              // Mensaje de error general
              Obx(() {
                final error =
                    controller.nameError.value ??
                    controller.emailError.value ??
                    controller.passwordError.value;

                if (error == null || error.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: isLight
                          ? AppTheme.primaryColor
                          : AppTheme.darkPrimarySoft,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 25),

              // Botón Registrarse
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() {
                  final isEnabled =
                      controller.canSubmitSignUp && !controller.isLoading.value;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLight
                          ? AppTheme.primaryColor
                          : AppTheme.darkButton,
                      disabledBackgroundColor: isLight
                          ? AppTheme.primaryColor.withOpacity(0.5)
                          : AppTheme.darkButtonDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: isEnabled ? 2 : 0,
                    ),
                    onPressed: isEnabled
                        ? () => controller.signUp(
                            controller.signUpEmailController.text.trim(),
                            controller.signUpPasswordController.text.trim(),
                            controller.signUpNameController.text.trim(),
                          )
                        : null,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Registrarse",
                            style: TextStyle(
                              fontSize: 18,
                              color: isEnabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
