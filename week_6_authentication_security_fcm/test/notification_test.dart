import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_6_authentication_security_fcm/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationProvider Tests', () {
    test('Daftar notifikasi awalnya kosong', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(notificationListProvider), isEmpty);
      expect(container.read(unreadNotificationCountProvider), 0);
    });

    test('Notifikasi berhasil masuk ke list dan menaikkan counter icon badge', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationListProvider.notifier);

      notifier.addNotification(
        id: '1',
        title: 'Jadwal Kuliah',
        body: 'Pindah ke ruang A2',
        route: '/pengumuman/1',
      );

      final list = container.read(notificationListProvider);
      final count = container.read(unreadNotificationCountProvider);

      expect(list.length, 1);
      expect(count, 1);
      expect(list.first.title, 'Jadwal Kuliah');
    });

    test('Ketika notifikasi dibaca, otomatis hilang dari list (Tugas 2) dan badge berkurang (Tugas 3)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationListProvider.notifier);

      notifier.addNotification(
        id: '101',
        title: 'Pengumuman 1',
        body: 'Isi pengumuman 1',
      );
      notifier.addNotification(
        id: '102',
        title: 'Pengumuman 2',
        body: 'Isi pengumuman 2',
      );

      expect(container.read(unreadNotificationCountProvider), 2);

      // User membaca notifikasi dengan ID 101 -> harus hilang dari list
      notifier.markAsReadAndRemove('101');

      final listAfterRead = container.read(notificationListProvider);
      final countAfterRead = container.read(unreadNotificationCountProvider);

      expect(listAfterRead.length, 1);
      expect(countAfterRead, 1);
      expect(listAfterRead.any((n) => n.id == '101'), isFalse);
      expect(listAfterRead.first.id, '102');

      // User membaca notifikasi 102 -> list jadi kosong dan badge jadi 0
      notifier.markAsReadAndRemove('102');
      expect(container.read(notificationListProvider), isEmpty);
      expect(container.read(unreadNotificationCountProvider), 0);
    });
  });
}
