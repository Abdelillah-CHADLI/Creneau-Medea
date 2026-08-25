enum GameStatus { open, full, cancelled, completed }

class Game {
  final int id;
  final String title;
  final DateTime startingTime;
  final DateTime endingTime;
  final int pitchId;
  final String? body;
  final int userId;
  final GameStatus status;
  final int price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    required this.id,
    required this.title,
    required this.startingTime,
    required this.endingTime,
    required this.pitchId,
    required this.body,
    required this.userId,
    required this.status,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      startingTime: DateTime.parse(json['starting_time']),
      endingTime: DateTime.parse(json['ending_time']),
      pitchId: json['pitch_id'],
      body: json['body'],
      userId: json['user_id'],
      status: GameStatus.values.byName(json['status']),
      price: json['price'],
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
      'status': status.name,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
