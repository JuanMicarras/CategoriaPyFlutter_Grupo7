import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/auth/ui/views/forgot_password_page.dart';

import '../widgets/auth_logo.dart';
import '../widgets/auth_input_container.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends GetView<AuthController> {
  LoginPage({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      authController.clearErrors();
      authController.passwordController.text = 'ThePassword!1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
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
                "Inicia Sesión",
                style: AppTheme.h1.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.textColor
                      : AppTheme.darkTextPrimary,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes una cuenta? ",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF8A8E97)
                          : Color(0xFFB0B0B0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/signup'),
                    child: Text(
                      "Regístrate",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
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
                    hint: "pepitojm@uninorte.edu.co",
                    icon: Icons.email_outlined,
                    isEmail: true,
                    controllerText: controller.emailController,
                    errorText: controller.emailError.value,
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black38
                        : Color(0xFF261C57),
                  ),
                  AuthTextField(
                    hint: "*******",
                    readOnly: false,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isLoginPassword: true,
                    controllerText: controller.passwordController,
                    errorText: controller.passwordError.value,
                  ),
                ],
              ),

              Obx(() {
                final error =
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
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.primaryColor
                          : AppTheme.darkPrimarySoft,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Get.to(() => ForgotPasswordPage());
                },
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Color.fromARGB(137, 21, 20, 20)
                        : AppTheme.grayColor100,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() {
                  final isEnabled = controller.canSubmitLogin && !controller.isLoading.value;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                          ? AppTheme.primaryColor
                          : AppTheme.darkButton,
                      disabledBackgroundColor:
                          Theme.of(context).brightness == Brightness.light
                          ? AppTheme.primaryColor.withOpacity(0.5)
                          : AppTheme.darkButtonDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: isEnabled ? 2 : 0,
                    ),
                    onPressed: isEnabled
                        ? () => controller.login(
                            controller.emailController.text.trim(),
                            controller.passwordController.text.trim(),
                          )
                        : null,
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Iniciar Sesión",
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
