enum RequestStatus { pending, rejected, accepted }

class Request {
  final int id;
  final int gameId;
  final int userId;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Request({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      gameId: json['game_id'],
      userId: json['user_id'],
      status: RequestStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'user_id': userId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
