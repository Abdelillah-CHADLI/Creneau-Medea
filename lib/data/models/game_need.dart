class GameNeed {
  final int gameId;
  final int needId;
  final int quantity;

  GameNeed({required this.gameId, required this.needId, this.quantity = 1});

  factory GameNeed.fromJson(Map<String, dynamic> json) {
    return GameNeed(
      gameId: (json['game_id'] as num).toInt(),
      needId: (json['need_id'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'game_id': gameId, 'need_id': needId, 'quantity': quantity};
  }
}
