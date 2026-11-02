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

