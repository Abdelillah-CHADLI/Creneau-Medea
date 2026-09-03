import 'dart:async';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/game.dart';
import '../models/app_notification.dart';
import '../models/game_need.dart';
import '../models/need.dart';
import '../models/pitch.dart';
import '../models/player_rating.dart';
import '../models/request.dart';
import '../models/reservation.dart';
import '../models/user.dart';
import 'local_store.dart';
import 'supabase_service.dart';

/// Unified data-access facade used by every screen.
///
/// When a Supabase project is configured it queries PostgREST directly,
/// otherwise it falls back to the seeded [LocalStore] so the app remains
/// fully usable offline.
class AppData {
  final SupabaseService supabase;
  final LocalStore local;

  AppData({required this.supabase, LocalStore? local})
    : local = local ?? LocalStore.instance;

  bool get _useSupabase => supabase.isConfigured;

  SupabaseClient get _db => supabase.client;

  // ---------------------------------------------------------------------
  // Auth profiles
  // ---------------------------------------------------------------------

  User? get currentUser => _useSupabase ? null : local.currentUser;

  /// Fetches a user profile by its id (auth uid when using Supabase).
  Future<User> fetchProfile(String id) async {
    if (!_useSupabase) {
      return local.users.firstWhere(
        (user) => user.id == id,
        orElse: () => throw Exception('الملف الشخصي غير موجود'),
      );
    }
    final row = await _db.from('users').select().eq('id', id).maybeSingle();
    if (row == null) throw Exception('الملف الشخصي غير موجود');
    return User.fromJson(_castMap(row));
  }

  /// Fetches the profiles referenced by player requests in one operation.
  /// Missing profiles are omitted so one incomplete profile never hides a
  /// match's entire request list.
  Future<Map<String, User>> fetchProfiles(Iterable<String> ids) async {
    final uniqueIds = ids.toSet().toList();
    if (uniqueIds.isEmpty) return {};
    if (!_useSupabase) {
      return {
        for (final user in local.users)
          if (uniqueIds.contains(user.id)) user.id: user,
      };
    }
    final rows = await _db.from('users').select().inFilter('id', uniqueIds);
    final profiles = rows.map((row) => User.fromJson(_castMap(row))).toList();
    return {for (final profile in profiles) profile.id: profile};
  }

  /// Creates/updates a user profile keyed by the Supabase auth id.
  Future<void> upsertProfile({
    required String id,
    String? fullname,
    String? username,
    String? phoneNumber,
    String? position,
    String? level,
  }) async {
    if (!_useSupabase) return;
    final values = <String, dynamic>{
      'id': id,
      'fullname': fullname,
      'phone_number': phoneNumber,
      'position': position,
      'level': level,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (username != null) values['username'] = username;
    await _db.from('users').upsert(values);
  }

  /// Updates the profile of the currently authenticated user and returns it.
  Future<User> updateCurrentUserProfile({
    String? fullname,
    String? phoneNumber,
    String? position,
    String? level,
  }) async {
    if (!_useSupabase) {
      await Future<void>.delayed(Duration.zero);
      return local.updateUser(
        fullname: fullname,
        phoneNumber: phoneNumber,
        position: position,
        level: level,
      );
    }
    final id = supabase.auth.currentUser!.id;
    await upsertProfile(
      id: id,
      fullname: fullname,
      phoneNumber: phoneNumber,
      position: position,
      level: level,
    );
    return fetchProfile(id);
  }

  // ---------------------------------------------------------------------
  // Pitches
  // ---------------------------------------------------------------------

  Future<List<Pitch>> pitches({String? condition}) async {
    if (!_useSupabase) {
      if (condition != null) {
        return local.pitches
            .where((p) => p.condition?.name == condition)
            .toList();
      }
      return List.of(local.pitches);
    }
    var query = _db.from('pitches').select();
    if (condition != null) query = query.eq('condition', condition);
    final rows = await query;
    return rows.map((r) => Pitch.fromJson(_castMap(r))).toList();
  }

  // ---------------------------------------------------------------------
  // Needs
  // ---------------------------------------------------------------------

  Future<List<Need>> needs() async {
    if (!_useSupabase) return List.of(local.needs);
    final rows = await _db.from('needs').select().order('id');
    return rows.map((r) => Need.fromJson(_castMap(r))).toList();
  }

  Future<List<GameNeed>> gameNeeds(int gameId) async {
    if (!_useSupabase) {
      return local.gameNeeds.where((n) => n.gameId == gameId).toList();
    }
    final rows = await _db.from('game_needs').select().eq('game_id', gameId);
    return rows.map((r) => GameNeed.fromJson(_castMap(r))).toList();
  }

  Future<Map<int, Set<String>>> gameNeedNamesForGames(
    Iterable<int> gameIds,
  ) async {
    final ids = gameIds.toSet().toList();
    if (ids.isEmpty) return {};
    final allNeeds = await needs();
    final namesById = {for (final need in allNeeds) need.id: need.name};
    final result = <int, Set<String>>{};
    if (!_useSupabase) {
      for (final item in local.gameNeeds.where(
        (item) => ids.contains(item.gameId),
      )) {
        final name = namesById[item.needId];
        if (name != null) result.putIfAbsent(item.gameId, () => {}).add(name);
      }
      return result;
    }
    final rows = await _db.from('game_needs').select().inFilter('game_id', ids);
    for (final row in rows) {
      final gameId = (row['game_id'] as num).toInt();
      final needId = (row['need_id'] as num).toInt();
      final name = namesById[needId];
      if (name != null) result.putIfAbsent(gameId, () => {}).add(name);
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // Games
  // ---------------------------------------------------------------------

  Future<List<Game>> games({
    String? status,
    int? pitchId,
    DateTime? from,
  }) async {
    if (!_useSupabase) {
      var list = List.of(local.games);
      if (status != null) {
        list = list
            .where(
              (g) =>
                  (g.status == GameStatus.inProgress
                      ? 'in_progress'
                      : g.status.name) ==
                  status,
            )
            .toList();
      }
      if (pitchId != null) {
        list = list.where((g) => g.pitchId == pitchId).toList();
      }
      if (from != null) {
        list = list.where((g) => g.startingTime.isAfter(from)).toList();
      }
      list.sort((a, b) => a.startingTime.compareTo(b.startingTime));
      return list;
    }
    var query = _db.from('games').select();
    if (status != null) query = query.eq('status', status);
    if (pitchId != null) query = query.eq('pitch_id', pitchId);
    if (from != null) {
      query = query.gte('starting_time', from.toIso8601String());
    }
    final rows = await query.order('starting_time');
    return rows.map((r) => Game.fromJson(_castMap(r))).toList();
  }

  Future<Game?> gameById(int id) async {
    if (!_useSupabase) {
      return local.games.where((g) => g.id == id).firstOrNull;
    }
    final row = await _db.from('games').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return Game.fromJson(_castMap(row));
  }

  Future<Game> createGame({
    String? title,
    required DateTime startingTime,
    required DateTime endingTime,
    required int pitchId,
    String? body,
    int? price,
    int maxPlayers = 10,
    List<String> needNames = const [],
  }) async {
    if (!_useSupabase) {
      final game = local.createGame(
        title: title,
        startingTime: startingTime,
        endingTime: endingTime,
        pitchId: pitchId,
        body: body,
        price: price,
        maxPlayers: maxPlayers,
      );
      _attachLocalNeeds(game.id, needNames);
      return game;
    }

    final userId = supabase.auth.currentUser!.id;
    final uniqueNeedNames = needNames.toSet();
    final allNeeds = uniqueNeedNames.isEmpty ? <Need>[] : await needs();
    final resolvedNeeds = uniqueNeedNames
        .map((name) => allNeeds.where((need) => need.name == name).firstOrNull)
        .whereType<Need>()
        .toList();
    if (resolvedNeeds.length != uniqueNeedNames.length) {
      final resolvedNames = resolvedNeeds.map((need) => need.name).toSet();
      final missing = uniqueNeedNames.difference(resolvedNames).join(', ');
      throw Exception('أنواع الاحتياج غير مهيأة في قاعدة البيانات: $missing');
    }
    final gameRow = await _db
        .from('games')
        .insert({
          'title': title,
          'starting_time': startingTime.toIso8601String(),
          'ending_time': endingTime.toIso8601String(),
          'pitch_id': pitchId,
          'body': body,
          'user_id': userId,
          'status': 'pending',
          'price': price,
          'max_players': maxPlayers,
        })
        .select()
        .single();
    final game = Game.fromJson(_castMap(gameRow));

    if (resolvedNeeds.isNotEmpty) {
      final rows = resolvedNeeds
          .map((n) => {'game_id': game.id, 'need_id': n.id, 'quantity': 1})
          .toList();
      await _db.from('game_needs').insert(rows);
    }
    return game;
  }

  void _attachLocalNeeds(int gameId, List<String> needNames) {
    for (final name in needNames) {
      final need = local.needs.where((n) => n.name == name).firstOrNull;
      if (need != null) {
        local.gameNeeds.add(GameNeed(gameId: gameId, needId: need.id));
      }
    }
  }

  // ---------------------------------------------------------------------
  // Requests
  // ---------------------------------------------------------------------

  Future<Request> sendJoinRequest(int gameId) async {
    final game = await gameById(gameId);
    if (game == null) throw Exception('المباراة غير موجودة');
    final currentId = _useSupabase
        ? supabase.auth.currentUser?.id
        : local.currentUser.id;
    if (game.userId == currentId) {
      throw Exception('لا يمكنك الانضمام إلى مباراة تنظمها');
    }
    if (game.status == GameStatus.cancelled ||
        game.status == GameStatus.finished) {
      throw Exception('هذه المباراة لم تعد متاحة للانضمام');
    }
    final accepted = await acceptedRequestCount(gameId);
    if (accepted >= game.maxPlayers) {
      throw Exception('اكتمل عدد اللاعبين في هذه المباراة');
    }
    if (!_useSupabase) {
      final request = local.sendRequest(gameId);
      local.addNotification(
        userId: game.userId,
        title: 'طلب انضمام جديد',
        body: 'لديك لاعب جديد بانتظار الموافقة.',
        type: 'join_request',
        gameId: gameId,
      );
      return request;
    }
    final userId = supabase.auth.currentUser!.id;
    final row = await _db
        .from('game_requests')
        .insert({'game_id': gameId, 'user_id': userId, 'status': 'pending'})
        .select()
        .single();
    return Request.fromJson(_castMap(row));
  }

  Future<Request> respondToRequest(int requestId, String status) async {
    if (status != 'accepted' && status != 'rejected') {
      throw ArgumentError.value(status, 'status');
    }
    final request = _useSupabase
        ? Request.fromJson(
            _castMap(
              await _db
                  .from('game_requests')
                  .select()
                  .eq('id', requestId)
                  .single(),
            ),
          )
        : local.requests.firstWhere((r) => r.id == requestId);
    if (status == 'accepted') {
      final game = await gameById(request.gameId);
      if (game == null ||
          await acceptedRequestCount(request.gameId) >= game.maxPlayers) {
        throw Exception('اكتمل عدد اللاعبين في هذه المباراة');
      }
    }
    if (!_useSupabase) {
      final idx = local.requests.indexWhere((r) => r.id == requestId);
      if (idx < 0) throw Exception('الطلب غير موجود');
      final current = local.requests[idx];
      final updated = Request(
        id: current.id,
        gameId: current.gameId,
        userId: current.userId,
        status: RequestStatus.values.asNameMap()[status] ?? current.status,
        attendance: current.attendance,
        archivedAt: current.archivedAt,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );
      local.requests[idx] = updated;
      local.addNotification(
        userId: updated.userId,
        title: status == 'accepted' ? 'تم قبول طلبك' : 'تم رفض طلبك',
        body: status == 'accepted'
            ? 'أنت الآن ضمن قائمة لاعبي المباراة.'
            : 'يمكنك استكشاف مباريات أخرى متاحة.',
        type: 'request_$status',
        gameId: updated.gameId,
      );
      return updated;
    }
    final row = await _db
        .from('game_requests')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .select()
        .single();
    return Request.fromJson(_castMap(row));
  }

  Future<Request> setAttendance(int requestId, String attendance) async {
    if (!_useSupabase) {
      final idx = local.requests.indexWhere((r) => r.id == requestId);
      if (idx < 0) throw Exception('الطلب غير موجود');
      final current = local.requests[idx];
      final updated = Request(
        id: current.id,
        gameId: current.gameId,
        userId: current.userId,
        status: current.status,
        attendance: AttendanceStatus.values.asNameMap()[attendance],
        archivedAt: current.archivedAt,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );
      local.requests[idx] = updated;
      return updated;
    }
    final row = await _db
        .from('game_requests')
        .update({'attendance_status': attendance})
        .eq('id', requestId)
        .select()
        .single();
    return Request.fromJson(_castMap(row));
  }

  Future<void> cancelRequest(int requestId) async {
    if (!_useSupabase) {
      local.requests.removeWhere((r) => r.id == requestId);
      return;
    }
    await _db.from('game_requests').delete().eq('id', requestId);
  }

  Future<int> acceptedRequestCount(int gameId) async {
    if (!_useSupabase) {
      return local.requests
          .where(
            (r) => r.gameId == gameId && r.status == RequestStatus.accepted,
          )
          .length;
    }
    final counts = await acceptedRequestCounts([gameId]);
    return counts[gameId] ?? 0;
  }

  Future<Map<int, int>> acceptedRequestCounts(Iterable<int> gameIds) async {
    final ids = gameIds.toSet().toList();
    if (ids.isEmpty) return {};
    final result = {for (final id in ids) id: 0};
    if (!_useSupabase) {
      for (final request in local.requests.where(
        (request) =>
            ids.contains(request.gameId) &&
            request.status == RequestStatus.accepted,
      )) {
        result[request.gameId] = (result[request.gameId] ?? 0) + 1;
      }
      return result;
    }
    final rows = await _db.rpc(
      'accepted_game_counts',
      params: {'game_ids': ids},
    );
    for (final row in rows) {
      final id = (row['game_id'] as num).toInt();
      result[id] = (row['accepted_count'] as num).toInt();
    }
    return result;
  }

  Future<void> cancelGame(int gameId) =>
      updateGame(gameId, status: GameStatus.cancelled);

  Future<Game> updateGame(
    int gameId, {
    String? title,
    DateTime? startingTime,
    DateTime? endingTime,
    int? pitchId,
    String? body,
    int? price,
    int? maxPlayers,
    GameStatus? status,
  }) async {
    final existing = await gameById(gameId);
    if (existing == null) throw Exception('المباراة غير موجودة');
    if (!_useSupabase) {
      final index = local.games.indexWhere((game) => game.id == gameId);
      final updated = Game(
        id: existing.id,
        title: title ?? existing.title,
        startingTime: startingTime ?? existing.startingTime,
        endingTime: endingTime ?? existing.endingTime,
        pitchId: pitchId ?? existing.pitchId,
        body: body ?? existing.body,
        userId: existing.userId,
        price: price ?? existing.price,
        maxPlayers: maxPlayers ?? existing.maxPlayers,
        archivedAt: existing.archivedAt,
        status: status ?? existing.status,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      local.games[index] = updated;
      if (status == GameStatus.cancelled) {
        for (final request in local.requests.where(
          (request) =>
              request.gameId == gameId &&
              request.status == RequestStatus.accepted,
        )) {
          local.addNotification(
            userId: request.userId,
            title: 'تم إلغاء المباراة',
            body: 'ألغى المنظم المباراة التي انضممت إليها.',
            type: 'game_cancelled',
            gameId: gameId,
          );
        }
      }
      return updated;
    }
    final changes = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (title != null) changes['title'] = title;
    if (startingTime != null) {
      changes['starting_time'] = startingTime.toIso8601String();
    }
    if (endingTime != null) {
      changes['ending_time'] = endingTime.toIso8601String();
    }
    if (pitchId != null) changes['pitch_id'] = pitchId;
    if (body != null) changes['body'] = body;
    if (price != null) changes['price'] = price;
    if (maxPlayers != null) changes['max_players'] = maxPlayers;
    if (status != null) {
      changes['status'] = status == GameStatus.inProgress
          ? 'in_progress'
          : status.name;
    }
    final row = await _db
        .from('games')
        .update(changes)
        .eq('id', gameId)
        .select()
        .single();
    return Game.fromJson(_castMap(row));
  }

  Future<List<Request>> requestsForGame(int gameId) async {
    if (!_useSupabase) {
      return local.requests.where((r) => r.gameId == gameId).toList();
    }
    final rows = await _db.from('game_requests').select().eq('game_id', gameId);
    return rows.map((r) => Request.fromJson(_castMap(r))).toList();
  }

  Future<Request?> myRequestForGame(int gameId) async {
    final userId = _useSupabase
        ? supabase.auth.currentUser?.id
        : local.currentUser.id;
    if (userId == null) return null;
    if (!_useSupabase) {
      return local.requests
          .where((r) => r.gameId == gameId && r.userId == userId)
          .firstOrNull;
    }
    final row = await _db
        .from('game_requests')
        .select()
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .maybeSingle();
    return row == null ? null : Request.fromJson(_castMap(row));
  }

  Future<List<AppNotification>> notifications() async {
    if (!_useSupabase) {
      final prefix = '${local.currentUser.id}::';
      return local.notifications
          .where((item) => item.type.startsWith(prefix))
          .map(
            (item) => AppNotification(
              id: item.id,
              title: item.title,
              body: item.body,
              type: item.type.substring(prefix.length),
              gameId: item.gameId,
              createdAt: item.createdAt,
              readAt: item.readAt,
            ),
          )
          .toList()
          .reversed
          .toList();
    }
    final rows = await _db
        .from('notifications')
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) => AppNotification.fromJson(_castMap(row))).toList();
  }

  Future<void> markNotificationRead(int id) async {
    if (!_useSupabase) return;
    await _db
        .from('notifications')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------
  // My games
  // ---------------------------------------------------------------------

  Future<List<Reservation>> myOrganizedGames({bool archived = false}) async {
    if (!_useSupabase) {
      return local.games
          .where(
            (g) =>
                g.userId == local.currentUser.id &&
                (g.archivedAt != null) == archived,
          )
          .map((game) {
            final pitch = local.pitches
                .where((pitch) => pitch.id == game.pitchId)
                .firstOrNull;
            return Reservation(
              request: Request(
                id: game.id,
                gameId: game.id,
                userId: game.userId,
                status: RequestStatus.accepted,
                createdAt: game.createdAt,
                updatedAt: game.updatedAt,
              ),
              game: game,
              pitch: pitch,
            );
          })
          .toList();
    }
    final userId = supabase.auth.currentUser!.id;
    final rows = await _db
        .from('games')
        .select('*, pitch:pitches(*)')
        .eq('user_id', userId)
        .order('starting_time');
    return rows
        .map((r) => _reservationFromGameRow(r))
        .where((item) => (item.game.archivedAt != null) == archived)
        .toList();
  }

  Future<List<Reservation>> myJoinedGames({bool archived = false}) async {
    if (!_useSupabase) {
      return local.requests
          .where(
            (r) =>
                r.userId == local.currentUser.id &&
                r.status == RequestStatus.accepted &&
                (r.archivedAt != null) == archived,
          )
          .map((r) {
            final game = local.games.where((g) => g.id == r.gameId).firstOrNull;
            if (game == null) {
              throw Exception('المباراة غير موجودة');
            }
            final pitch = local.pitches
                .where((pitch) => pitch.id == game.pitchId)
                .firstOrNull;
            return Reservation(request: r, game: game, pitch: pitch);
          })
          .toList();
    }
    final userId = supabase.auth.currentUser!.id;
    final rows = await _db
        .from('game_requests')
        .select('*, game:games(*, pitch:pitches(*))')
        .eq('user_id', userId)
        .eq('status', 'accepted');
    return rows
        .map((r) => _reservationFromRequestRow(r))
        .where((item) => (item.request.archivedAt != null) == archived)
        .toList();
  }

  Future<void> setOrganizedGameArchived(int gameId, bool archived) async {
    final value = archived ? DateTime.now() : null;
    if (!_useSupabase) {
      final index = local.games.indexWhere((game) => game.id == gameId);
      if (index < 0) throw Exception('المباراة غير موجودة');
      final game = local.games[index];
      local.games[index] = Game(
        id: game.id,
        title: game.title,
        startingTime: game.startingTime,
        endingTime: game.endingTime,
        pitchId: game.pitchId,
        body: game.body,
        userId: game.userId,
        status: game.status,
        price: game.price,
        maxPlayers: game.maxPlayers,
        archivedAt: value,
        createdAt: game.createdAt,
        updatedAt: DateTime.now(),
      );
      return;
    }
    await _db
        .from('games')
        .update({'archived_at': value?.toIso8601String()})
        .eq('id', gameId);
  }

  Future<void> setJoinedGameArchived(int requestId, bool archived) async {
    final value = archived ? DateTime.now() : null;
    if (!_useSupabase) {
      final index = local.requests.indexWhere(
        (request) => request.id == requestId,
      );
      if (index < 0) throw Exception('طلب الانضمام غير موجود');
      final request = local.requests[index];
      local.requests[index] = Request(
        id: request.id,
        gameId: request.gameId,
        userId: request.userId,
        status: request.status,
        attendance: request.attendance,
        archivedAt: value,
        createdAt: request.createdAt,
        updatedAt: DateTime.now(),
      );
      return;
    }
    await _db
        .from('game_requests')
        .update({'archived_at': value?.toIso8601String()})
        .eq('id', requestId);
  }

  // ---------------------------------------------------------------------
  // Ratings
  // ---------------------------------------------------------------------

  Future<PlayerRating> ratePlayer({
    required int gameRequestId,
    required int gameId,
    required String playerId,
    required String organizerId,
    required int rating,
  }) async {
    if (!_useSupabase) {
      final now = DateTime.now();
      final pr = PlayerRating(
        id: now.millisecondsSinceEpoch,
        gameRequestId: gameRequestId,
        gameId: gameId,
        playerId: playerId,
        organizerId: organizerId,
        rating: rating,
        createdAt: now,
      );
      local.ratings.add(pr);
      final index = local.users.indexWhere((user) => user.id == playerId);
      if (index >= 0) {
        final user = local.users[index];
        final count = user.ratingCount + 1;
        final average = ((user.rating * user.ratingCount) + rating) / count;
        final updated = User(
          id: user.id,
          fullname: user.fullname,
          username: user.username,
          phoneNumber: user.phoneNumber,
          position: user.position,
          level: user.level,
          rating: average,
          ratingCount: count,
          createdAt: user.createdAt,
          updatedAt: now,
        );
        local.users[index] = updated;
        if (local.currentUser.id == playerId) local.currentUser = updated;
      }
      return pr;
    }
    final row = await _db
        .from('player_ratings')
        .insert({
          'game_request_id': gameRequestId,
          'game_id': gameId,
          'player_id': playerId,
          'organizer_id': organizerId,
          'rating': rating,
        })
        .select()
        .single();
    return PlayerRating.fromJson(_castMap(row));
  }

  Future<List<PlayerRating>> ratingsForPlayer(String playerId) async {
    if (!_useSupabase) {
      return local.ratings
          .where((rating) => rating.playerId == playerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    final rows = await _db
        .from('player_ratings')
        .select()
        .eq('player_id', playerId)
        .order('created_at', ascending: false);
    return rows.map((row) => PlayerRating.fromJson(_castMap(row))).toList();
  }

  Future<List<PlayerRating>> ratingsForGame(int gameId) async {
    if (!_useSupabase) {
      return local.ratings.where((rating) => rating.gameId == gameId).toList();
    }
    final rows = await _db
        .from('player_ratings')
        .select()
        .eq('game_id', gameId);
    return rows.map((row) => PlayerRating.fromJson(_castMap(row))).toList();
  }

  // ---------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------

  Reservation _reservationFromGameRow(Map<String, dynamic> row) {
    // `row` is a game row (possibly with `pitch` embedded).
    final request = Request.fromJson({
      'id': row['id'],
      'game_id': row['id'],
      'user_id': row['user_id'],
      'status': 'accepted',
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    });
    final game = Game.fromJson({
      'id': row['id'],
      'title': row['title'],
      'starting_time': row['starting_time'],
      'ending_time': row['ending_time'],
      'pitch_id': row['pitch_id'],
      'body': row['body'],
      'user_id': row['user_id'],
      'status': row['status'],
      'price': row['price'],
      'max_players': row['max_players'],
      'archived_at': row['archived_at'],
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    });
    final pitchRow = row['pitch'];
    Pitch? pitch;
    if (pitchRow is Map<String, dynamic>) {
      pitch = Pitch.fromJson({
        'id': pitchRow['id'],
        'name': pitchRow['name'],
        'location': pitchRow['location'],
        'condition': pitchRow['condition'],
        'created_at': pitchRow['created_at'],
        'updated_at': pitchRow['updated_at'],
      });
    }
    return Reservation(request: request, game: game, pitch: pitch);
  }

  Reservation _reservationFromRequestRow(Map<String, dynamic> row) {
    // `row` is a game_request row with `game` embedded.
    final request = Request.fromJson({
      'id': row['id'],
      'game_id': row['game_id'],
      'user_id': row['user_id'],
      'status': row['status'],
      'attendance': row['attendance_status'],
      'archived_at': row['archived_at'],
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
    });
    final gameRow = row['game'];
    Game? game;
    Pitch? pitch;
    if (gameRow is Map<String, dynamic>) {
      game = Game.fromJson({
        'id': gameRow['id'],
        'title': gameRow['title'],
        'starting_time': gameRow['starting_time'],
        'ending_time': gameRow['ending_time'],
        'pitch_id': gameRow['pitch_id'],
        'body': gameRow['body'],
        'user_id': gameRow['user_id'],
        'status': gameRow['status'],
        'price': gameRow['price'],
        'max_players': gameRow['max_players'],
        'archived_at': gameRow['archived_at'],
        'created_at': gameRow['created_at'],
        'updated_at': gameRow['updated_at'],
      });
      final pitchRow = gameRow['pitch'];
      if (pitchRow is Map<String, dynamic>) {
        pitch = Pitch.fromJson({
          'id': pitchRow['id'],
          'name': pitchRow['name'],
          'location': pitchRow['location'],
          'condition': pitchRow['condition'],
          'created_at': pitchRow['created_at'],
          'updated_at': pitchRow['updated_at'],
        });
      }
    }
    if (game == null) throw Exception('المباراة غير موجودة');
    return Reservation(request: request, game: game, pitch: pitch);
  }

  Map<String, dynamic> _castMap(Map<String, dynamic> row) =>
      row.map((key, value) => MapEntry(key, value));
}
