import 'package:creneau_medea/data/models/game.dart';
import 'package:creneau_medea/data/models/request.dart';
import 'package:creneau_medea/data/services/app_data.dart';
import 'package:creneau_medea/data/services/supabase_service.dart';
import 'package:creneau_medea/presentation/screens/request/create_request_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 9, 3, 18);

  test('database in_progress status maps to the Dart enum and back', () {
    final game = Game.fromJson({
      'id': 1,
      'starting_time': now.toIso8601String(),
      'ending_time': now.add(const Duration(hours: 1)).toIso8601String(),
      'pitch_id': 2,
      'user_id': 'user-1',
      'status': 'in_progress',
      'max_players': 13,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    expect(game.status, GameStatus.inProgress);
    expect(game.maxPlayers, 13);
    expect(game.toJson()['status'], 'in_progress');
  });

  test('nullable Supabase attendance is not interpreted as absent', () {
    final pendingAttendance = Request.fromJson({
      'id': 8,
      'game_id': 1,
      'user_id': 'user-2',
      'status': 'accepted',
      'attendance_status': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    final attended = Request.fromJson({
      ...pendingAttendance.toJson(),
      'attendance_status': 'attended',
    });

    expect(pendingAttendance.attendance, isNull);
    expect(attended.attendance, AttendanceStatus.attended);
  });

  test('request details require a user-written title', () {
    final request = CreateRequestData()
      ..pitchName = 'ملعب زرواق'
      ..date = now
      ..startTime = const TimeOfDay(hour: 18, minute: 0)
      ..endTime = const TimeOfDay(hour: 19, minute: 0);

    expect(request.isStep2Complete, isFalse);
    request.title = 'تحدي حي المصلى';
    expect(request.isStep2Complete, isTrue);
  });

  test('archiving preserves a game instead of changing its status', () {
    final archivedAt = now.add(const Duration(hours: 2));
    final game = Game.fromJson({
      'id': 4,
      'title': 'مباراة مؤرشفة',
      'starting_time': now.toIso8601String(),
      'ending_time': now.add(const Duration(hours: 1)).toIso8601String(),
      'pitch_id': 1,
      'user_id': 'user-1',
      'status': 'finished',
      'archived_at': archivedAt.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    expect(game.archivedAt, archivedAt);
    expect(game.status, GameStatus.finished);
    expect(game.toJson()['archived_at'], archivedAt.toIso8601String());
  });

  test(
    'ball and pump needs persist together and archived games can return',
    () async {
      final data = AppData(supabase: SupabaseService());
      final game = await data.createGame(
        title: 'اختبار الاحتياجات',
        startingTime: now.add(const Duration(days: 1)),
        endingTime: now.add(const Duration(days: 1, hours: 1)),
        pitchId: 1,
        maxPlayers: 4,
        needNames: const ['players', 'football', 'pump'],
      );
      final needIds = data.local.gameNeeds
          .where((item) => item.gameId == game.id)
          .map((item) => item.needId)
          .toSet();
      final savedNames = data.local.needs
          .where((need) => needIds.contains(need.id))
          .map((need) => need.name)
          .toSet();

      expect(savedNames, containsAll(<String>['players', 'football', 'pump']));
      await data.setOrganizedGameArchived(game.id, true);
      expect(
        (await data.myOrganizedGames()).any((item) => item.game.id == game.id),
        isFalse,
      );
      expect(
        (await data.myOrganizedGames(
          archived: true,
        )).any((item) => item.game.id == game.id),
        isTrue,
      );
      await data.setOrganizedGameArchived(game.id, false);
      expect(
        (await data.myOrganizedGames()).any((item) => item.game.id == game.id),
        isTrue,
      );
    },
  );
}
