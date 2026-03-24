import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/widgets/settings_card.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el controlador de autenticación global
    final authController = Get.find<AuthController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Encabezado
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Perfil",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8F72C9),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. Información del Usuario (Reactiva con Obx)
            Obx(() {
              final user = authController.user;
              final email = user?.email ?? 'usuario@ejemplo.com';
              
              // Extraemos la primera letra para el Avatar
              final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U';
              
              // Como la entidad AuthUser actual solo tiene ID, Email y Rol,
              // extraemos un "nombre" cortando lo que está antes del @
              final name = email.split('@').first;

              return Column(
                children: [
                  // Avatar circular con la primera letra
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor500, // Morado claro del tema
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor, // Morado oscuro
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nombre extraído
                  Text(
                    name,
                    style: AppTheme.h3.copyWith(color: AppTheme.textColor),
                  ),
                  const SizedBox(height: 4),
                  
                  // Correo completo
                  Text(
                    email,
                    style: AppTheme.bodyM.copyWith(color: Colors.grey),
                  ),
                ],
              );
            }),

            const SizedBox(height: 40),

            // 3. Tarjeta de Configuraciones con la lógica inyectada
            SettingsCard(
              items: [
                SettingsCardItem(
                  title: 'Notificaciones',
                  onTap: () {
                    Get.snackbar('Notificaciones', 'Próximamente...');
                  },
                ),
                SettingsCardItem(
                  title: 'Privacidad y seguridad',
                  onTap: () {
                    Get.snackbar('Privacidad', 'Próximamente...');
                  },
                ),
                SettingsCardItem(
                  title: 'Cerrar sesión',
                  onTap: () {
                    // Diálogo de confirmación nativo de GetX
                    Get.defaultDialog(
                      title: "Cerrar Sesión",
                      middleText: "¿Estás seguro de que quieres salir?",
                      textCancel: "Cancelar",
                      textConfirm: "Salir",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      cancelTextColor: AppTheme.primaryColor,
                      onConfirm: () {
                        // Llamamos al método que creamos antes
                        authController.signOut();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}