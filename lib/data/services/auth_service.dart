import '../models/user.dart';
import 'package:collection/collection.dart';
import 'app_data.dart';
import 'local_store.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

class AuthResult {
  final User user;
  final String token;

  AuthResult({required this.user, required this.token});
}

class AuthService {
  final SupabaseService _supabase;
  final StorageService _storage;
  final AppData _appData;

  User? _currentUser;

  AuthService({
    required SupabaseService supabase,
    required StorageService storage,
    required AppData appData,
  }) : this._(supabase, storage, appData);

  AuthService._(this._supabase, this._storage, this._appData);

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _supabase.isConfigured
      ? _supabase.auth.currentSession != null
      : _currentUser != null;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    if (!_supabase.isConfigured) {
      // Offline: accept any email/password.
      return _localSignIn(email);
    }
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _currentUser = await _fetchProfile(res.user!.id);
    _cacheProfile();
    return AuthResult(
      user: _currentUser!,
      token: res.session?.accessToken ?? '',
    );
  }

  Future<AuthResult> signUp({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
    String? position,
    String? level,
  }) async {
    if (position == null || level == null) {
      throw Exception('يرجى اختيار مركز ومستوى اللعب');
    }
    if (!_supabase.isConfigured) {
      return _localSignUp(fullname, email, phoneNumber, position, level);
    }
    final res = await _supabase.auth.signUp(email: email, password: password);
    if (res.user == null) {
      throw Exception('تعذر إنشاء الحساب، يرجى المحاولة مجدداً.');
    }
    // Mirror the profile row into the `users` table (id = auth uid).
    await _appData.upsertProfile(
      id: res.user!.id,
      fullname: fullname,
      username: '${email.split('@').first}_${res.user!.id.substring(0, 6)}',
      phoneNumber: phoneNumber,
      position: position,
      level: level,
    );
    _currentUser = await _fetchProfile(res.user!.id);
    _cacheProfile();
    return AuthResult(
      user: _currentUser!,
      token: res.session?.accessToken ?? '',
    );
  }

  Future<void> signOut() async {
    if (_supabase.isConfigured) {
      await _supabase.auth.signOut();
    }
    _currentUser = null;
    await _storage.clearSession();
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_supabase.isConfigured) {
      throw Exception('إعادة تعيين كلمة المرور متاحة عند ربط التطبيق بالخدمة');
    }
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Updates the current user's profile (name, phone, position, level).
  Future<User> updateProfile({
    String? fullname,
    String? phoneNumber,
    String? position,
    String? level,
  }) async {
    final updated = await _appData.updateCurrentUserProfile(
      fullname: fullname,
      phoneNumber: phoneNumber,
      position: position,
      level: level,
    );
    _currentUser = updated;
    _cacheProfile();
    return updated;
  }

  Future<void> restoreSession() async {
    if (!_supabase.isConfigured) {
      final stored = await _storage.getCurrentUser();
      if (stored != null) {
        _currentUser = User.fromJson(stored);
        LocalStore.instance.activateUser(_currentUser!);
      } else {
        _currentUser = LocalStore.instance.currentUser;
      }
      return;
    }
    // Supabase persists the session in shared_preferences on its own.
    final session = _supabase.auth.currentSession;
    if (session == null) return;
    try {
      _currentUser = await _fetchProfile(session.user.id);
      _cacheProfile();
    } catch (_) {
      // Profile row may not exist yet; keep session anyway.
    }
  }

  Future<User> _fetchProfile(String authUserId) async {
    final row = await _appData.fetchProfile(authUserId);
    return row;
  }

  void _cacheProfile() {
    if (_currentUser != null) {
      _storage.setCurrentUser(_currentUser!.toJson());
    }
  }

  // --- Offline (local store) helpers -----------------------------------

  Future<AuthResult> _localSignIn(String email) async {
    final username = email.split('@').first;
    final store = LocalStore.instance;
    final existing = store.users
        .where((user) => user.username == username)
        .firstOrNull;
    _currentUser =
        existing ??
        User(
          id: 'local_${username.hashCode & 0x3fffffff}',
          fullname: 'محمد شادي',
          username: username,
          phoneNumber: '0555123456',
          position: null,
          level: null,
          rating: 4.8,
          ratingCount: 15,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        );
    store.activateUser(_currentUser!);
    _cacheProfile();
    return AuthResult(user: _currentUser!, token: 'local_token');
  }

  Future<AuthResult> _localSignUp(
    String fullname,
    String email,
    String phoneNumber,
    String? position,
    String? level,
  ) async {
    final username = email.split('@').first;
    final user = LocalStore.instance.createUser(
      fullname: fullname,
      username: username,
      phoneNumber: phoneNumber,
      position: position,
      level: level,
    );
    _currentUser = user;
    LocalStore.instance.activateUser(user);
    _cacheProfile();
    return AuthResult(user: user, token: 'local_token');
  }
}
