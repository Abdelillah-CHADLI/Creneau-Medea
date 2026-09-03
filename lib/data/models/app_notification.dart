class AppNotification {
  final int id;
  final String title;
  final String body;
  final String type;
  final int? gameId;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.gameId,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String,
        gameId: (json['game_id'] as num?)?.toInt(),
        createdAt: DateTime.parse(json['created_at']),
        readAt: json['read_at'] == null
            ? null
            : DateTime.parse(json['read_at']),
      );
}
