import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart'; // Asegúrate de que la ruta sea correcta
import 'package:peer_sync/core/themes/app_theme.dart';

class SignUpPage extends GetView<AuthController> {
  SignUpPage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Fondo suave
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Get.back(), // Navegación nativa de GetX
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/icon/logo.png', height: 120),
              const SizedBox(height: 20),

              // Título
              Text(
                "Crear cuenta",
                style: AppTheme.h1.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              // Subtítulo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Ya tienes una cuenta? ",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Get.back(), // Regresa al login que ya está en la pila
                    child: Text(
                      "Inicia sesión",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      context,
                      hint: "Nombre completo",
                      icon: Icons.person_outline,
                      textController: controller.signUpNameController,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _buildTextField(
                      context,
                      hint: "Correo electrónico",
                      icon: Icons.email_outlined,
                      textController: controller.signUpEmailController,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _buildTextField(
                      context,
                      hint: "Contraseña",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      textController: controller.signUpPasswordController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary, // Color morado del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            // Aquí llamaremos al método de registro de tu controlador
                            // NOTA: Como aún no agregas 'nombre' a tu modelo, lo omitimos por ahora
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

  // Widget reutilizable para los campos de texto
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
        style: TextStyle(color: theme.colorScheme.onSurface),
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

    // SOLO el password necesita Obx
    return Obx(
      () => TextField(
        controller: textController,
        obscureText: controller.obscurePassword.value,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
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