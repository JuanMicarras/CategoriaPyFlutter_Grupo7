import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/features/auth/ui/viewmodels/auth_controller.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Definición de colores principales basados en la foto
    const purpleColor = AppTheme.primaryColor;
    const whiteColor = AppTheme.backgroundColor;

    return Scaffold(
      backgroundColor: purpleColor, 
      // AppBar personalizado
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección 1: Cabecera con Avatar (Obx para reaccionar al usuario)
            Obx(() {
              final user = authController.user;
              // Imagen placeholder o imagen real del usuario si ROBLE la devuelve
              const imageUrl =
                  "https://www.w3schools.com/howto/img_avatar.png"; // Placeholder
              
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: whiteColor,
                      child: ClipOval(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user?.email ?? 'Nombre de Usuario', // Usamos el email como nombre por ahora
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'joined 1 yr ago', // TODO: Obtener fecha real
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              );
            }),

            // Sección 2: Contenedor Blanco Inferior (con bordes redondeados)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  
                  // 2.2: Lista de opciones (Basado en la foto)
                  // TODO: Si ya tienes estos widgets en core/widgets, reemplázalos por _SettingTile
                  _SettingTile(title: "Account", icon: Icons.person_outline),
                  _SettingTile(title: "Notifications", icon: Icons.notifications_none_outlined),
                  _SettingTile(title: "Settings", icon: Icons.settings_outlined),
                  _SettingTile(title: "Help & Support", icon: Icons.help_outline),

                  const SizedBox(height: 15),
                  const Divider(), // Línea divisoria antes del Logout
                  const SizedBox(height: 15),

                  // 2.3: Botón de Cerrar Sesión (OPERATIVO)
                  _SettingTile(
                    title: "Logout",
                    icon: Icons.power_settings_new_outlined,
                    isLogout: true,
                    onTap: () {
                      // Diálogo de confirmación con GetX
                      Get.defaultDialog(
                        title: "Cerrar Sesión",
                        middleText: "¿Estás seguro de que quieres salir?",
                        textCancel: "Cancelar",
                        textConfirm: "Salir",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.redAccent,
                        onConfirm: () {
                          // TODO: Implementar lógica de cerrar sesión en el controlador
                          authController.signOut();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES (Placeholders locales) ---
// TAREA: Si ya tienes estos widgets en lib/core/widgets/, borra estos de aquí
// y usa tus imports. De lo contrario, múevelos a lib/core/widgets/ para reutilizarlos.

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color(0xFF6C63FF);
    final isBrowser =
        Get.context != null && (Get.context?.mounted ?? false) && false; // Placeholder para web
    
    return Container(
      width: isBrowser ? 110 : Get.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: purpleColor, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isLogout;
  final VoidCallback? onTap;

  const _SettingTile({
    Key? key,
    required this.title,
    required this.icon,
    this.isLogout = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isLogout ? Colors.redAccent : Colors.black87;
    final iconColor = isLogout ? Colors.redAccent : Colors.grey[600];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ??
          () {
            // TODO: Navegación genérica
            Get.snackbar('Navegación', 'No implementado para $title');
          },
    );
  }
}