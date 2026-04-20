import '../../domain/models/app_notification.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/remote/notification_remote_source.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationRemoteSource _remoteSource;

  NotificationRepositoryImpl(this._remoteSource);

  @override
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    final data = await _remoteSource.getUserNotifications(userId);
    
    return data.map((json) {
      return AppNotification(
        id: json['_id'].toString(),
        userId: json['user_id'].toString(),
        title: json['title'].toString(),
        body: json['body'].toString(),
        isRead: json['is_read'] == true || json['is_read'] == 'true',
        // Parseamos la fecha o le ponemos la actual si falla
        createdAt: DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _remoteSource.markAsRead(notificationId);
  }
}