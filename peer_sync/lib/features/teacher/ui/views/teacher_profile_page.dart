import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/utils/teacher_navigation_helpers.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/widgets/settings_card.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // 1. Obtenemos el controlador de autenticación global
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: isLight
          ? AppTheme.backgroundColor
          : AppTheme.darkBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Encabezado
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Perfil",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isLight ? const Color(0xFF8F72C9) : AppTheme.darkTextPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. Información del Usuario (Reactiva con Obx)
              Obx(() {
                final user = authController.user;
                final email = user?.email ?? 'usuario@ejemplo.com';

                // Extraemos la primera letra para el Avatar
                final firstLetter = email.isNotEmpty
                    ? email[0].toUpperCase()
                    : 'U';

                final name = user?.name ?? 'Estudiante';

                return Column(
                  children: [
                    // Avatar circular con la primera letra
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor500,
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre extraído
                    Text(
                      name,
                      style: AppTheme.h3.copyWith(
                        color: isLight
                            ? AppTheme.textColor
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Correo completo
                    Text(
                      email,
                      style: AppTheme.bodyM.copyWith(
                        color: isLight ? Colors.grey : AppTheme.darkTextMuted,
                      ),
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
                      Get.to(() => const NotificationsPage());
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
                        titleStyle: TextStyle(fontWeight: FontWeight.bold),
                        middleText: "¿Estás seguro de que quieres salir?",
                        textCancel: "Cancelar",
                        textConfirm: "Salir",
                        confirmTextColor: Colors.white,
                        buttonColor: AppTheme.primaryColor300,
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
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 2, // 2 = Perfil
        onTap: (index) => TeacherNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
