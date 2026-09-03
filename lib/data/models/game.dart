enum GameStatus { pending, cancelled, inProgress, finished }

class Game {
  final int id;
  final String? title;
  final DateTime startingTime;
  final DateTime endingTime;
  final int pitchId;
  final String? body;
  final String userId;
  final GameStatus status;
  final int? price;
  final int maxPlayers;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    required this.id,
    this.title,
    required this.startingTime,
    required this.endingTime,
    required this.pitchId,
    this.body,
    required this.userId,
    required this.status,
    this.price,
    this.maxPlayers = 10,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status'] as String;
    return Game(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      startingTime: DateTime.parse(json['starting_time']),
      endingTime: DateTime.parse(json['ending_time']),
      pitchId: (json['pitch_id'] as num).toInt(),
      body: json['body'] as String?,
      userId: '${json['user_id']}',
      status: statusValue == 'in_progress'
          ? GameStatus.inProgress
          : GameStatus.values.byName(statusValue),
      price: (json['price'] as num?)?.toInt(),
      maxPlayers: (json['max_players'] as num? ?? 10).toInt(),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'starting_time': startingTime.toIso8601String(),
      'ending_time': endingTime.toIso8601String(),
      'pitch_id': pitchId,
      'body': body,
      'user_id': userId,
      'status': status == GameStatus.inProgress ? 'in_progress' : status.name,
      'price': price,
      'max_players': maxPlayers,
      'archived_at': archivedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
