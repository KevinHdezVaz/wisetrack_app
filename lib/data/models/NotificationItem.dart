class NotificationItem {
  final String title;
  final String description;
  final String time;
  final String? date; // Opcional, para notificaciones más antiguas
  final String avatarUrl;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    this.date,
    required this.avatarUrl,
    this.isUnread = false,
  });
}
