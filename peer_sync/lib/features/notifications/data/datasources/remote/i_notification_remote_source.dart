
abstract class INotificationRemoteSource {
  Future<List<dynamic>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
}