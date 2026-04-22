import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import '../viewmodels/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark
              ? AppTheme.darkPrimarySoft
              : AppTheme.primaryColor,
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
                style: AppTheme.h1.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un enlace para restablecer tu contraseña.",
                style: AppTheme.bodyM.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "Correo electrónico",
                style: AppTheme.bodyM.copyWith(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.primaryColor200,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: controller.resetEmailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF5F6FA),
                  hintText: 'ejemplo@uninorte.edu.co',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppTheme.darkButton
                        : AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.sendPasswordReset(),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar enlace',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
