import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import '../viewmodels/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  ForgotPasswordPage({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      authController.clearErrors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.backgroundColor
          : AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.primaryColor
              : AppTheme.darkPrimarySoft,
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Recuperar contraseña",
                style: AppTheme.h2.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.primaryColor
                      : AppTheme.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un enlace para restablecer tu contraseña.",
                style: AppTheme.bodyM.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[600]
                      : AppTheme.darkTextSecondary,
                ),
              ),
              const SizedBox(height: 40),

              Text(
                "Correo electrónico",
                style: AppTheme.bodyM.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.primaryColor200
                      : AppTheme.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              AuthTextField(
                hint: "ejemplo@uninorte.edu.co",
                icon: Icons.email_outlined,
                isEmail: true,
                controllerText: controller.resetEmailController,
                errorText: controller.emailError.value,
              ),

              Obx(() {
                final error = controller.emailError.value;
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

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() {
                  final isEnabled =
                      !controller.isLoading.value &&
                      controller.resetEmailText.value.trim().isNotEmpty &&
                      controller.emailError.value == null;

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
                        ? () => controller.sendPasswordReset()
                        : null,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Enviar enlace',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isEnabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
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
