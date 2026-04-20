import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/widgets/settings_card.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/features/notifications/ui/views/notifications_page.dart';
import 'package:peer_sync/core/widgets/navbar.dart';
import 'package:peer_sync/core/utils/student_navigation_helpers.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final authController = Get.find<AuthController>();

    // 1. Envolvemos la vista en un Scaffold propio
    return Scaffold(
      backgroundColor: isLight
          ? AppTheme.backgroundColor
          : AppTheme.darkBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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

              Obx(() {
                final user = authController.user;
                final email = user?.email ?? 'usuario@ejemplo.com';
                final firstLetter = email.isNotEmpty
                    ? email[0].toUpperCase()
                    : 'U';
                final name = user?.name ?? 'Estudiante';

                return Column(
                  children: [
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
                    Text(
                      name,
                      style: AppTheme.h3.copyWith(
                        color: isLight
                            ? AppTheme.textColor
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
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

              SettingsCard(
                items: [
                  SettingsCardItem(
                    title: 'Notificaciones',
                    onTap: () => Get.to(() => const NotificationsPage()),
                  ),
                  SettingsCardItem(
                    title: 'Privacidad y seguridad',
                    onTap: () => Get.snackbar('Privacidad', 'Próximamente...'),
                  ),
                  SettingsCardItem(
                    title: 'Cerrar sesión',
                    onTap: () {
                      Get.defaultDialog(
                        title: "Cerrar Sesión",
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        middleText: "¿Estás seguro de que quieres salir?",
                        textCancel: "Cancelar",
                        textConfirm: "Salir",
                        confirmTextColor: Colors.white,
                        buttonColor: AppTheme.primaryColor300,
                        cancelTextColor: AppTheme.primaryColor,
                        onConfirm: () => authController.signOut(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // 2. Agregamos el NavBar inyectando la lógica centralizada
      bottomNavigationBar: NavBar(
        currentIndex: 2, // 2 = Perfil
        onTap: (index) => StudentNavigationHelpers.handleNavTap(index),
      ),
    );
  }
}
