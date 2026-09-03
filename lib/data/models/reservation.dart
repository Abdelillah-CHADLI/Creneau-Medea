import 'game.dart';
import 'pitch.dart';
import 'request.dart';

class Reservation {
  final Request request;
  final Game game;
  final Pitch? pitch;

  Reservation({required this.request, required this.game, this.pitch});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      request: json['request'] is Map<String, dynamic>
          ? Request.fromJson(json['request'])
          : Request.fromJson({'game_id': json['game_id'], ...json}),
      game: json['game'] is Map<String, dynamic>
          ? Game.fromJson(json['game'])
          : Game.fromJson(json),
      pitch: json['pitch'] is Map<String, dynamic>
          ? Pitch.fromJson(json['pitch'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request': request.toJson(),
      'game': game.toJson(),
      'pitch': pitch?.toJson(),
    };
  }
}
