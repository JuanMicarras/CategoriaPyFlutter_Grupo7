import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart'; // Asegúrate de que la ruta sea correcta
import 'package:peer_sync/core/themes/app_theme.dart';

class SignUpPage extends GetView<AuthController> {
  SignUpPage({super.key});
  // En un proyecto real, estos controladores deberían definirse y limpiarse
  // dentro del AuthController para separar la lógica de la UI, pero para
  // propósitos visuales iniciales los pondremos aquí.
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Fondo suave
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
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
              const Text(
                "Crear cuenta",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A3F),
                ),
              ),

              // Subtítulo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿Ya tienes una cuenta? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Get.back(), // Regresa al login que ya está en la pila
                    child: const Text(
                      "Inicia sesión",
                      style: TextStyle(
                        color: Color(0xFF9D74DE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      hint: "Nombre completo",
                      icon: Icons.person_outline,
                      textController: controller.signUpNameController,
                    ),
                    const Divider(height: 1),
                    _buildTextField(
                      hint: "Correo electrónico",
                      icon: Icons.email_outlined,
                      textController: controller.signUpEmailController,
                    ),
                    const Divider(height: 1),
                    _buildTextField(
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
                      backgroundColor: const Color(
                        0xFF7A58BC,
                      ), // Color morado del botón
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
                            style: TextStyle(fontSize: 18, color: Colors.white),
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
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController textController,
  }) {
    if (!isPassword) {
      return TextField(
        controller: textController,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)),
          border: InputBorder.none,
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
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)),
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
