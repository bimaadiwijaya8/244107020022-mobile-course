import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs in a background isolate: do not access BuildContext, widgets,
  // GoRouter, or Riverpod state here.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class PushService {
  PushService({
    required Dio dioClient,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _dio = dioClient,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  static const _topic = 'pengumuman-kampus';

  final Dio _dio;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  void Function(String route)? _go;
  void Function(RemoteMessage message)? _onMessageReceived;
  String? _pendingLocalRoute;

  Future<AuthorizationStatus> requestPermission() async {
    // Android 13+: this requests the POST_NOTIFICATIONS runtime permission.
    // iOS: this requests the user's alert, badge, and sound authorization.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus;
  }

  Future<void> initialize({
    required void Function(String route) go,
    void Function(RemoteMessage message)? onMessageReceived,
  }) async {
    _go = go;
    _onMessageReceived = onMessageReceived;
    await _initializeLocalNotifications();
    await requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _registerTokenSafely(token);

    _subscriptions.add(
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        unawaited(_registerTokenSafely(token));
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        _onMessageReceived?.call(message);
        unawaited(_showForegroundNotification(message));
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _onMessageReceived?.call(message);
        _navigateFromMessage(message);
      }),
    );

    await subscribeToCampusAnnouncements();
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) _go?.call(route);
      },
    );

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _pendingLocalRoute = launchDetails?.notificationResponse?.payload;
    }
  }

  Future<void> _registerTokenSafely(String token) async {
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => defaultTargetPlatform.name,
    };

    try {
      await _dio.post<void>(
        '/devices',
        data: {'fcm_token': token, 'platform': platform},
      );
    } on DioException catch (error) {
      debugPrint('Failed to register FCM token: ${error.message}');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final route = message.data['route'] as String? ?? '/';
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        channelDescription: 'Notifikasi pengumuman kampus',
        importance: Importance.high,
        priority: Priority.high,
        channelShowBadge: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: message.hashCode & 0x7fffffff,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: details,
      payload: route,
    );
  }

  /// Menampilkan notifikasi lokal langsung (termasuk untuk simulasi)
  Future<void> showLocalNotificationDirect({
    required int id,
    required String title,
    required String body,
    String route = '/',
    int badgeCount = 1,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        channelDescription: 'Notifikasi pengumuman kampus',
        importance: Importance.high,
        priority: Priority.high,
        channelShowBadge: true,
        number: badgeCount,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: badgeCount,
      ),
    );

    await _localNotifications.show(
      id: id & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: details,
      payload: route,
    );
  }

  /// Menghapus notifikasi dari status bar / notification drawer
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id & 0x7fffffff);
  }

  /// Menghapus semua notifikasi dari status bar
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  void _navigateFromMessage(RemoteMessage message) {
    _go?.call(message.data['route'] as String? ?? '/');
  }

  Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _onMessageReceived?.call(message);
      _navigateFromMessage(message);
      return;
    }

    final route = _pendingLocalRoute;
    _pendingLocalRoute = null;
    if (route != null && route.isNotEmpty) _go?.call(route);
  }

  Future<void> subscribeToCampusAnnouncements() async {
    await FirebaseMessaging.instance.subscribeToTopic(_topic);
  }

  Future<void> unsubscribeFromCampusAnnouncements() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(_topic);
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
