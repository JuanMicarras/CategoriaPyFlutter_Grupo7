import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/auth_controller.dart';
import '../../../../core/app_theme.dart'; // Importamos tu tema centralizado

class SignUpPage extends GetView<AuthController> {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // Fondo oscuro de tu tema
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor), // Flecha blanca
          onPressed: () => Get.back(), // Excelente uso de la navegación nativa de GetX
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo desde assets
              Image.asset('assets/icon/icon.png', height: 100),
              const SizedBox(height: 20),
              
              // Título
              const Text(
                "Crear cuenta", 
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.textColor, // Texto blanco
                ),
              ),
              
              // Subtítulo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? ", style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () => Get.back(), // Regresa al login que ya está en la pila de GetX
                    child: const Text(
                      "Inicia sesión", 
                      style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
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
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      hint: "Nombre completo", 
                      icon: Icons.person_outline, 
                      textController: controller.signUpNameController, // Conectado al controller
                    ),
                    const Divider(height: 1),
                    _buildTextField(
                      hint: "Correo electrónico", 
                      icon: Icons.email_outlined, 
                      textController: controller.signUpEmailController, // Conectado al controller
                    ),
                    const Divider(height: 1),
                    _buildTextField(
                      hint: "Contraseña", 
                      icon: Icons.lock_outline, 
                      isPassword: true, 
                      textController: controller.signUpPasswordController, // Conectado al controller
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Botón de Registrarse reactivo
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, // Usamos tu color primario (morado)
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: controller.isLoading 
                    ? null 
                    : () {
                        // Enviamos los datos reales; nota: agregaremos el nombre al modelo más adelante
                        controller.signUp(
                          controller.signUpEmailController.text.trim(), 
                          controller.signUpPasswordController.text.trim(), 
                          'student' // Rol por defecto por ahora
                        );
                      },
                  child: controller.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Registrarse", 
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

  // Widget reutilizable adaptado
  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    bool isPassword = false, 
    required TextEditingController textController,
  }) {
    return TextField(
      controller: textController,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black87), // Letra oscura porque el fondo es blanco
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.6)), // Icono primario
        suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined, color: Colors.grey) : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      ),
    );
  }
}