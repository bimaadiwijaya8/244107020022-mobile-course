import '../../repositories/push_notification_repository.dart';

class CancelNotificationUseCase {
  final PushNotificationRepository _repository;

  CancelNotificationUseCase(this._repository);

  Future<void> execute(int id) {
    return _repository.cancelNotification(id);
  }

  Future<void> executeAll() {
    return _repository.cancelAllNotifications();
  }
}

