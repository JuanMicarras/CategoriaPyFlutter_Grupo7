import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

import '../../../../core/app_theme.dart'; // Importamos tu tema centralizado

// Extendemos de GetView para inyectar automáticamente tu AuthController
class LoginPage extends GetView<AuthController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Usamos tu color de fondo definido en el AppTheme
      backgroundColor: AppTheme.backgroundColor, 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. Logo cargado desde la carpeta de assets
              Image.asset('assets/icon/icon.png', height: 120),
              const SizedBox(height: 20),
              
              // 3. Título usando el color de texto claro de tu tema
              const Text(
                "Inicia Sesión", 
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.textColor,
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes una cuenta? ", style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    // Navegación purista con GetX a la vista de registro
                    onTap: () => Get.toNamed('/signup'),
                    child: const Text(
                      "Regístrate", 
                      style: TextStyle(
                        color: AppTheme.secondaryColor, // Color secundario para el enlace
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      hint: "pepitojm@uninorte.edu.co", 
                      icon: Icons.email_outlined,
                      // 4. Conectamos con el controlador de GetX
                      textController: controller.emailController, 
                    ),
                    const Divider(height: 1),
                    _buildTextField(
                      hint: "*******", 
                      icon: Icons.lock_outline, 
                      isPassword: true,
                      // 4. Conectamos con el controlador de GetX
                      textController: controller.passwordController, 
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {}, 
                child: const Text(
                  "¿Olvidaste tu contraseña?", 
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Botón de Iniciar Sesión reactivo
              SizedBox(
                width: double.infinity,
                height: 55,
                // Obx escucha los cambios de _isLoading en tu AuthController
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, // Color primario para el botón principal
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: controller.isLoading 
                    ? null // Si está cargando, deshabilitamos el botón
                    : () {
                        // Enviamos los datos reales capturados en la UI al viewmodel
                        controller.login(
                          controller.emailController.text.trim(), 
                          controller.passwordController.text.trim()
                        );
                      },
                  child: controller.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Iniciar Sesión", 
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método privado para construir los campos de texto
  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    bool isPassword = false,
    required TextEditingController textController,
  }) {
    return TextField(
      controller: textController,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black87), // Texto oscuro porque el fondo del input es blanco
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)), // Icono con el color primario
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      ),
    );
  }
}