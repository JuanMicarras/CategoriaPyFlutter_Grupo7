import 'package:get/get.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/models/app_notification.dart';
import '../../../auth/ui/viewmodels/auth_controller.dart';

class NotificationController extends GetxController {
  final INotificationRepository repository;
  final AuthController authController = Get.find();

  final notifications = <AppNotification>[].obs;
  final isLoading = false.obs;

  NotificationController(this.repository);

  // Propiedad calculada para saber cuántas no se han leído
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications(); // Cargamos al iniciar la app
  }

  Future<void> loadNotifications() async {
    final myEmail = authController.user?.email;
    if (myEmail == null) return;

    try {
      isLoading.value = true;
      final result = await repository.getUserNotifications(myEmail);

      // Las ordenamos para que las más nuevas salgan arriba
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.assignAll(result);
    } catch (e) {
      print("Error cargando notificaciones: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return; // Si ya está leída, no hacemos nada

    try {
      await repository.markAsRead(notification.id);
      // Actualizamos la lista localmente para que la UI reaccione al instante
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = AppNotification(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          body: notification.body,
          isRead: true, // Cambiamos a leída
          createdAt: notification.createdAt,
        );
      }
    } catch (e) {
      print("Error marcando como leída: $e");
    }
  }
}
