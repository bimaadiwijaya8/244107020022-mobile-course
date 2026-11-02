abstract class PushNotificationRepository {
  Future<void> initialize({
    required void Function(String route) go,
    void Function(dynamic message)? onMessageReceived,
  });

  Future<void> showLocalNotificationDirect({
    required int id,
    required String title,
    required String body,
    String route = '/',
    int badgeCount = 1,
  });

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();

  Future<void> handleInitialMessage();

  Future<void> subscribeToCampusAnnouncements();

  Future<void> unsubscribeFromCampusAnnouncements();

  Future<void> dispose();
}

