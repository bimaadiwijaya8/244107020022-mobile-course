import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dependency_injection.dart';
import '../../providers/notification_provider.dart';

class NotificationHomePage extends ConsumerWidget {
  const NotificationHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final notifications = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth & FCM'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // TASK 3: NOTIF MASUK DI ICON
          Badge.count(
            count: unreadCount,
            isLabelVisible: unreadCount > 0,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: 'Kotak Masuk Notifikasi',
              onPressed: () => context.push('/notifications'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar? Token tersimpan akan dihapus.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Card Info (Bukti Login Berhasil via Firebase Auth API)
            Card(
              elevation: 2,
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status: Terautentikasi (Firebase Auth API)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.email ?? 'Pengguna',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Token tersimpan aman di FlutterSecureStorage',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notification Status & Simulation Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Badge.count(
                              count: unreadCount,
                              isLabelVisible: unreadCount > 0,
                              child: Icon(
                                Icons.notifications_active,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kotak Notifikasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  unreadCount > 0
                                      ? '$unreadCount notifikasi belum dibaca'
                                      : 'Semua notifikasi sudah dibaca',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        FilledButton.tonal(
                          onPressed: () => context.push('/notifications'),
                          child: const Text('Buka Kotak'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_alert, size: 18),
                      label: const Text('Simulasi Notifikasi Masuk (FCM Test)'),
                      onPressed: () {
                        ref
                            .read(notificationListProvider.notifier)
                            .simulateNotification();
                        final list = ref.read(notificationListProvider);
                        if (list.isNotEmpty) {
                          final first = list.first;
                          ref
                              .read(showLocalNotificationUseCaseProvider)
                              .execute(
                                id: int.tryParse(first.id) ??
                                    DateTime.now().millisecondsSinceEpoch,
                                title: first.title,
                                body: first.body,
                                route: first.route,
                                badgeCount: list.length,
                              );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notifikasi baru berhasil masuk ke icon & list!',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // TASK 2: Notifikasi List di Halaman Utama (Ketika dibaca hilang)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Notifikasi Aktif (${notifications.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: () => context.push('/notifications'),
                    child: const Text('Lihat Detail'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (notifications.isEmpty)
              Card(
                color: Colors.grey.withAlpha(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.done_all,
                        size: 40,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Daftar notifikasi kosong.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ketika notifikasi dibaca, otomatis hilang dari daftar ini.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Icon(
                                  Icons.notifications,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Text(
                              item.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  minimumSize: const Size(0, 32),
                                ),
                                icon: const Icon(Icons.info_outline, size: 14),
                                label: const Text(
                                  'Detail',
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  _showNotificationDetailDialog(
                                    context,
                                    ref,
                                    item,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                style: FilledButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  minimumSize: const Size(0, 32),
                                ),
                                icon: const Icon(Icons.check, size: 14),
                                label: const Text(
                                  'Baca',
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  ref
                                      .read(notificationListProvider.notifier)
                                      .markAsReadAndRemove(item.id);

                                  final remaining = ref
                                      .read(notificationListProvider)
                                      .length;
                                  ref
                                      .read(cancelNotificationUseCaseProvider)
                                      .execute(int.tryParse(item.id) ?? 0);
                                  if (remaining == 0) {
                                    ref
                                        .read(
                                            cancelNotificationUseCaseProvider)
                                        .executeAll();
                                  }

                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Notifikasi "${item.title}" dibaca dan langsung hilang.',
                                      ),
                                      duration: const Duration(
                                        milliseconds: 1200,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetailDialog(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.mark_email_read_outlined,
          color: Colors.deepPurple,
          size: 36,
        ),
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.body,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (item.route.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Target rute: ${item.route}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Tandai Dibaca & Hapus'),
            onPressed: () {
              ref
                  .read(notificationListProvider.notifier)
                  .markAsReadAndRemove(item.id);
              final remaining = ref.read(notificationListProvider).length;
              ref
                  .read(cancelNotificationUseCaseProvider)
                  .execute(int.tryParse(item.id) ?? 0);
              if (remaining == 0) {
                ref.read(cancelNotificationUseCaseProvider).executeAll();
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notifikasi "${item.title}" telah dihapus.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          if (item.route.startsWith('/pengumuman/'))
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(item.route);
              },
              child: const Text('Buka Pengumuman'),
            ),
        ],
      ),
    );
  }
}
