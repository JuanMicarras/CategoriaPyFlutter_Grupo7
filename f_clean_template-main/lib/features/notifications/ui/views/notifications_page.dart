import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import '../viewmodels/notification_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    // Refrescamos al entrar a la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadNotifications();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const Center(child: Text("No tienes notificaciones nuevas.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            
            // Formateo simple de fecha
            final dateStr = "${notif.createdAt.day}/${notif.createdAt.month} ${notif.createdAt.hour}:${notif.createdAt.minute.toString().padLeft(2, '0')}";

            return Dismissible(
              key: Key(notif.id),
              direction: DismissDirection.endToStart, // Solo deslizar de derecha a izquierda
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                // Borramos de la lista visualmente al instante
                controller.notifications.removeAt(index);
                
                //TODO: Crear método en el controller para eliminar la notificación del backend
                
              },
              child: InkWell(
                onTap: () {
                  controller.markAsRead(notif);
                },
                child: Container(
                  color: notif.isRead ? Colors.transparent : AppTheme.secondaryColor.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4, right: 16),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: notif.isRead ? Colors.transparent : AppTheme.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 16, color: AppTheme.textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(notif.body, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}