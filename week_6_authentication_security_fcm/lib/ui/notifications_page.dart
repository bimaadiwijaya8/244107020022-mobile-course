import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);
    final count = notifications.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Kotak Notifikasi'),
            const SizedBox(width: 8),
            if (count > 0)
              Badge.count(
                count: count,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulasi Notifikasi Masuk',
            icon: const Icon(Icons.notification_add_outlined),
            onPressed: () {
              ref.read(notificationListProvider.notifier).simulateNotification();
              final list = ref.read(notificationListProvider);
              if (list.isNotEmpty) {
                final first = list.first;
                ref.read(pushServiceProvider).showLocalNotificationDirect(
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
                  content: Text('Notifikasi simulasi baru telah masuk ke list!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          if (notifications.isNotEmpty)
            IconButton(
              tooltip: 'Hapus Semua',
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(notificationListProvider.notifier).clearAll();
                ref.read(pushServiceProvider).cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi dibersihkan.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak Ada Notifikasi Aktif',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketika notifikasi dibaca, otomatis hilang dari daftar ini.\nKirim notifikasi dari Firebase Console atau gunakan tombol di bawah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.add_alert),
                      label: const Text('Simulasi Notifikasi Masuk'),
                      onPressed: () {
                        ref
                            .read(notificationListProvider.notifier)
                            .simulateNotification();
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                final formattedTime =
                    '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')}';

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(notificationListProvider.notifier)
                        .markAsReadAndRemove(item.id);
                  },
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(40),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Ketuk Card: Membuka detail notifikasi
                        _showNotificationDetail(context, item, ref);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_active,
                                size: 24,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.body,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // TOMBOL DETAIL: Melihat detail notifikasi
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          visualDensity:
                                              VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
                                          minimumSize: const Size(0, 32),
                                        ),
                                        icon: const Icon(
                                          Icons.info_outline,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Detail',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () {
                                          _showNotificationDetail(
                                            context,
                                            item,
                                            ref,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),

                                      // TOMBOL BACA: LANGSUNG HILANG DARI LIST
                                      FilledButton.tonalIcon(
                                        style: FilledButton.styleFrom(
                                          visualDensity:
                                              VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 0,
                                          ),
                                          minimumSize: const Size(0, 32),
                                        ),
                                        icon: const Icon(
                                          Icons.check,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Baca',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () {
                                          // Langsung hilang seketika dari list
                                          ref
                                              .read(
                                                notificationListProvider
                                                    .notifier,
                                              )
                                              .markAsReadAndRemove(item.id);

                                          final remaining = ref
                                              .read(notificationListProvider)
                                              .length;
                                          ref
                                              .read(pushServiceProvider)
                                              .cancelNotification(
                                                int.tryParse(item.id) ?? 0,
                                              );
                                          if (remaining == 0) {
                                            ref
                                                .read(pushServiceProvider)
                                                .cancelAllNotifications();
                                          }

                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    NotificationItem item,
    WidgetRef ref,
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
            Text(item.body),
            const SizedBox(height: 16),
            if (item.route.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Target Rute: ${item.route}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
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
                  .read(pushServiceProvider)
                  .cancelNotification(int.tryParse(item.id) ?? 0);
              if (remaining == 0) {
                ref.read(pushServiceProvider).cancelAllNotifications();
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
