import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

// Extendemos de GetView para inyectar automáticamente tu AuthController
class LoginPage extends GetView<AuthController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset('assets/icon/logo.png', height: 120),
              const SizedBox(height: 20),

              Text(
                "Inicia Sesión",
                style: AppTheme.h1.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes una cuenta? ",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),

                  GestureDetector(
                    // Navegación purista con GetX a la vista de registro
                    onTap: () => Get.toNamed('/signup'),
                    child: Text(
                      "Regístrate",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Contenedor de Inputs
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .shadowColor
                          .withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    _buildTextField(
                      context,
                      hint: "pepitojm@uninorte.edu.co",
                      icon: Icons.email_outlined,
                      textController: controller.emailController,
                    ),

                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    ),

                    _buildTextField(
                      context,
                      hint: "*******",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      textController: controller.passwordController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botón de Iniciar Sesión reactivo
              SizedBox(
                width: double.infinity,
                height: 55,

                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
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
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
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

  Widget _buildTextField(
    BuildContext context, {
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController textController,
  }) {

    final theme = Theme.of(context);

    if (!isPassword) {
      return TextField(
        controller: textController,

        style: TextStyle(
          color: theme.colorScheme.onSurface,
        ),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),

          prefixIcon: Icon(
            icon,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),

          filled: true,
          fillColor: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      );
    }

    return Obx(
      () => TextField(
        controller: textController,
        obscureText: controller.obscurePassword.value,

        style: TextStyle(
          color: theme.colorScheme.onSurface,
        ),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),

          prefixIcon: Icon(
            icon,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),

          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),

          filled: true,
          fillColor: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}