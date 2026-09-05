import '../models/game.dart';
import '../models/app_notification.dart';
import '../models/game_need.dart';
import '../models/need.dart';
import '../models/pitch.dart';
import '../models/player_rating.dart';
import '../models/request.dart';
import '../models/user.dart';

/// Seeded in-memory data store used when the Supabase project is not yet
/// configured. Mirrors the DBML schema so the offline flow feels real.
class LocalStore {
  LocalStore._() {
    _seed();
  }

  static final LocalStore instance = LocalStore._();

  int _nextUserId = 100;
  int _nextGameId = 100;
  int _nextRequestId = 100;
  int _nextNotificationId = 100;

  final List<User> users = [];
  final List<Game> games = [];
  final List<Request> requests = [];
  final List<Need> needs = [];
  final List<GameNeed> gameNeeds = [];
  final List<Pitch> pitches = [];
  final List<PlayerRating> ratings = [];
  final List<AppNotification> notifications = [];

  void addNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    int? gameId,
  }) {
    notifications.add(
      AppNotification(
        id: _nextNotificationId++,
        title: title,
        body: body,
        type: '$userId::$type',
        gameId: gameId,
        createdAt: DateTime.now(),
      ),
    );
  }

  User currentUser = User(
    id: '1',
    fullname: 'محمد شادي',
    username: 'm_chadli',
    phoneNumber: '0555123456',
    position: 'وسط',
    level: 'intermediate',
    rating: 4.8,
    ratingCount: 15,
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    updatedAt: DateTime.now(),
  );

  void _seed() {
    final now = DateTime.now();

    pitches.addAll([
      Pitch(
        id: 1,
        name: 'ملعب الأولمبي',
        location: 'شارع الاستقلال، المدية',
        condition: ConditionType.good,
        createdAt: now,
        updatedAt: now,
      ),
      Pitch(
        id: 2,
        name: 'ملعب 5 جويلية',
        location: 'حي 5 جويلية 1962، المدية',
        condition: ConditionType.good,
        createdAt: now,
        updatedAt: now,
      ),
      Pitch(
        id: 3,
        name: 'ملعب النجم',
        location: 'طريق بوسماحة، المدية',
        condition: ConditionType.average,
        createdAt: now,
        updatedAt: now,
      ),
      Pitch(
        id: 4,
        name: 'ملعب البلدية',
        location: 'وسط المدينة، المدية',
        condition: ConditionType.average,
        createdAt: now,
        updatedAt: now,
      ),
      Pitch(
        id: 5,
        name: 'ملعب الشباب',
        location: 'حي بري، المدية',
        condition: ConditionType.good,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    needs.addAll([
      Need(id: 1, name: 'players'),
      Need(id: 2, name: 'opponent'),
      Need(id: 3, name: 'football'),
      Need(id: 5, name: 'pump'),
      Need(id: 6, name: 'pitch_available'),
    ]);

    users.add(currentUser);
    users.addAll([
      User(
        id: '2',
        fullname: 'أحمد خالد',
        username: 'ahmed_k',
        phoneNumber: '0556112233',
        position: 'هجوم',
        level: 'advanced',
        rating: 4.9,
        ratingCount: 22,
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now,
      ),
      User(
        id: '3',
        fullname: 'يوسف عبد الرحمن',
        username: 'youssef',
        phoneNumber: '0556223344',
        position: 'وسط',
        level: 'intermediate',
        rating: 4.5,
        ratingCount: 18,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
      ),
    ]);

    final t1 = now.copyWith(hour: 18, minute: 0);
    final g1 = Game(
      id: 1,
      title: 'مباراة ودية - ملعب الأولمبي',
      startingTime: t1,
      endingTime: t1.add(const Duration(hours: 1)),
      pitchId: 1,
      body: 'نحتاج لاعبين',
      userId: '1',
      status: GameStatus.pending,
      price: 500,
      createdAt: now,
      updatedAt: now,
    );
    games.add(g1);
    gameNeeds.add(GameNeed(gameId: 1, needId: 1, quantity: 2));
    gameNeeds.add(GameNeed(gameId: 1, needId: 3, quantity: 1));

    final t2 = now.add(const Duration(days: 1)).copyWith(hour: 20, minute: 0);
    final g2 = Game(
      id: 2,
      title: 'تحدي الأحياء',
      startingTime: t2,
      endingTime: t2.add(const Duration(hours: 1)),
      pitchId: 3,
      body: 'نبحث عن خصم',
      userId: '2',
      status: GameStatus.pending,
      price: 400,
      createdAt: now,
      updatedAt: now,
    );
    games.add(g2);
    gameNeeds.add(GameNeed(gameId: 2, needId: 2, quantity: 1));

    final t3 = now.add(const Duration(days: 2)).copyWith(hour: 16, minute: 0);
    final g3 = Game(
      id: 3,
      title: 'مباراة ودية - شباب الحي',
      startingTime: t3,
      endingTime: t3.add(const Duration(hours: 1)),
      pitchId: 4,
      body: 'نحتاج لاعبين',
      userId: '3',
      status: GameStatus.pending,
      price: 500,
      createdAt: now,
      updatedAt: now,
    );
    games.add(g3);
    gameNeeds.add(GameNeed(gameId: 3, needId: 1, quantity: 2));
  }

  User createUser({
    required String fullname,
    required String username,
    required String phoneNumber,
    String? position,
    String? level,
  }) {
    final now = DateTime.now();
    final user = User(
      id: '${_nextUserId++}',
      fullname: fullname,
      username: username,
      phoneNumber: phoneNumber,
      position: position,
      level: level,
      rating: 0,
      ratingCount: 0,
      createdAt: now,
      updatedAt: now,
    );
    users.add(user);
    currentUser = user;
    return user;
  }

  /// Keeps the offline data facade and authentication state on the same user.
  void activateUser(User user) {
    final index = users.indexWhere((candidate) => candidate.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    currentUser = user;
  }

  User updateUser({
    String? fullname,
    String? phoneNumber,
    String? position,
    String? level,
  }) {
    final updated = User(
      id: currentUser.id,
      fullname: fullname ?? currentUser.fullname,
      username: currentUser.username,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      position: position ?? currentUser.position,
      level: level ?? currentUser.level,
      rating: currentUser.rating,
      ratingCount: currentUser.ratingCount,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
    );
    final idx = users.indexWhere((u) => u.id == currentUser.id);
    if (idx >= 0) {
      users[idx] = updated;
    } else {
      users.add(updated);
    }
    currentUser = updated;
    return updated;
  }

  Game createGame({
    String? title,
    required DateTime startingTime,
    required DateTime endingTime,
    required int pitchId,
    String? body,
    String? status,
    int? price,
    int maxPlayers = 10,
  }) {
    final now = DateTime.now();
    final game = Game(
      id: _nextGameId++,
      title: title,
      startingTime: startingTime,
      endingTime: endingTime,
      pitchId: pitchId,
      body: body,
      userId: currentUser.id,
      status: GameStatus.values.asNameMap()[status] ?? GameStatus.pending,
      price: price,
      maxPlayers: maxPlayers,
      createdAt: now,
      updatedAt: now,
    );
    games.add(game);
    return game;
  }

  Request sendRequest(int gameId) {
    if (games.every((game) => game.id != gameId)) {
      throw Exception('المباراة غير موجودة');
    }
    if (requests.any(
      (request) => request.gameId == gameId && request.userId == currentUser.id,
    )) {
      throw Exception('لقد أرسلت طلب انضمام لهذه المباراة بالفعل');
    }
    final now = DateTime.now();
    final request = Request(
      id: _nextRequestId++,
      gameId: gameId,
      userId: currentUser.id,
      status: RequestStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    requests.add(request);
    return request;
  }
}
