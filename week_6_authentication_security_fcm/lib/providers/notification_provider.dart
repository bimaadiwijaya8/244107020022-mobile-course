import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String route;
  final DateTime timestamp;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.timestamp,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? route,
    DateTime? timestamp,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class NotificationListNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    _syncLauncherBadge(0);
    return [];
  }

  /// Sinkronisasi angka badge ke Icon Aplikasi Launcher (seperti WA / Telegram)
  Future<void> _syncLauncherBadge(int count) async {
    try {
      final isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        await AppBadgePlus.updateBadge(count);
      }
    } catch (e) {
      debugPrint('Launcher tidak mendukung badge icon: $e');
    }
  }

  /// Menambahkan notifikasi baru ke dalam list (posisi paling atas)
  void addNotification({
    required String id,
    required String title,
    required String body,
    String route = '/',
  }) {
    final item = NotificationItem(
      id: id,
      title: title,
      body: body,
      route: route,
      timestamp: DateTime.now(),
    );

    // Hapus jika sudah ada ID sama (hindari duplikat), lalu taruh di paling depan
    state = [item, ...state.where((n) => n.id != id)];
    _syncLauncherBadge(state.length);
  }

  /// Menghapus notifikasi ketika dibaca (sesuai instruksi: "ketika di baca hilang")
  void markAsReadAndRemove(String id) {
    state = state.where((item) => item.id != id).toList();
    _syncLauncherBadge(state.length);
  }

  /// Menghapus semua notifikasi
  void clearAll() {
    state = [];
    _syncLauncherBadge(0);
  }

  /// Simulasi notifikasi untuk mempermudah testing praktikum
  void simulateNotification({
    String? title,
    String? body,
    String? route,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final sampleTitles = [
      'Jadwal Kuliah Berubah',
      'Pengumuman Beasiswa',
      'Nilai Kuis Dirilis',
      'Peringatan Batas KRS',
    ];
    final sampleBodies = [
      'Kelas Mobile pindah ke Lab Komputer 3 jam 14:00.',
      'Pendaftaran beasiswa prestasi dibuka hingga akhir bulan.',
      'Nilai kuis Week 6 telah diperbarui di sistem akademik.',
      'Segera selesaikan pengisian KRS sebelum pukul 23:59 WIB.',
    ];
    final index = (state.length) % sampleTitles.length;

    addNotification(
      id: id,
      title: title ?? sampleTitles[index],
      body: body ?? sampleBodies[index],
      route: route ?? '/pengumuman/$id',
    );
  }
}

final notificationListProvider =
    NotifierProvider<NotificationListNotifier, List<NotificationItem>>(
  NotificationListNotifier.new,
);

/// Provider untuk menghitung jumlah notifikasi aktif (untuk badge icon)
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationListProvider).length;
});
