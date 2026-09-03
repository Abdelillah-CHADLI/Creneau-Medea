class PlayerRating {
  final int id;
  final int gameRequestId;
  final int gameId;
  final String playerId;
  final String organizerId;
  final int rating;
  final DateTime createdAt;

  PlayerRating({
    required this.id,
    required this.gameRequestId,
    required this.gameId,
    required this.playerId,
    required this.organizerId,
    required this.rating,
    required this.createdAt,
  });

  factory PlayerRating.fromJson(Map<String, dynamic> json) {
    return PlayerRating(
      id: (json['id'] as num).toInt(),
      gameRequestId: (json['game_request_id'] as num).toInt(),
      gameId: (json['game_id'] as num).toInt(),
      playerId: '${json['player_id']}',
      organizerId: '${json['organizer_id']}',
      rating: (json['rating'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_request_id': gameRequestId,
      'game_id': gameId,
      'player_id': playerId,
      'organizer_id': organizerId,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
