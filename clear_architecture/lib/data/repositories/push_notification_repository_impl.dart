import '../../domain/repositories/push_notification_repository.dart';
import '../datasources/push_notification_remote_datasource.dart';

class PushNotificationRepositoryImpl implements PushNotificationRepository {
  PushNotificationRepositoryImpl(this._remoteDataSource);

  final PushNotificationRemoteDataSource _remoteDataSource;

  @override
  Future<void> initialize({
    required void Function(String route) go,
    void Function(dynamic message)? onMessageReceived,
  }) {
    return _remoteDataSource.initialize(
      go: go,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  Future<void> showLocalNotificationDirect({
    required int id,
    required String title,
    required String body,
    String route = '/',
    int badgeCount = 1,
  }) {
    return _remoteDataSource.showLocalNotificationDirect(
      id: id,
      title: title,
      body: body,
      route: route,
      badgeCount: badgeCount,
    );
  }

  @override
  Future<void> cancelNotification(int id) {
    return _remoteDataSource.cancelNotification(id);
  }

  @override
  Future<void> cancelAllNotifications() {
    return _remoteDataSource.cancelAllNotifications();
  }

  @override
  Future<void> handleInitialMessage() {
    return _remoteDataSource.handleInitialMessage();
  }

  @override
  Future<void> subscribeToCampusAnnouncements() {
    return _remoteDataSource.subscribeToCampusAnnouncements();
  }

  @override
  Future<void> unsubscribeFromCampusAnnouncements() {
    return _remoteDataSource.unsubscribeFromCampusAnnouncements();
  }

  @override
  Future<void> dispose() {
    return _remoteDataSource.dispose();
  }
}
