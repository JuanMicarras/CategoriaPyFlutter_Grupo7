import '../models/app_notification.dart';

abstract class INotificationRepository {
  Future<List<AppNotification>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
}