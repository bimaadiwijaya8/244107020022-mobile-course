import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/push_notification_remote_datasource.dart';
import 'firebase_options.dart';
import 'presentation/providers/dependency_injection.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  registerBackgroundHandler();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(routerProvider);
      final pushRepo = ref.read(pushNotificationRepositoryProvider);

      await pushRepo.initialize(
        go: router.go,
        onMessageReceived: (message) {
          final route = (message.data?['route'] as String?) ?? '/';
          final title = message.notification?.title ?? 'Pengumuman Baru';
          final body = message.notification?.body ?? '';
          final id = message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString();

          ref.read(notificationListProvider.notifier).addNotification(
                id: id,
                title: title,
                body: body,
                route: route,
              );
        },
      );
      pushRepo.handleInitialMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Week 6 - Auth & FCM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
