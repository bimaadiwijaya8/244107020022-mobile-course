import '../../repositories/push_notification_repository.dart';

class ShowLocalNotificationUseCase {
  final PushNotificationRepository _repository;

  ShowLocalNotificationUseCase(this._repository);

  Future<void> execute({
    required int id,
    required String title,
    required String body,
    String route = '/',
    int badgeCount = 1,
  }) {
    return _repository.showLocalNotificationDirect(
      id: id,
      title: title,
      body: body,
      route: route,
      badgeCount: badgeCount,
    );
  }
}

