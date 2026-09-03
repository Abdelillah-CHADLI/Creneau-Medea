import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps the [Supabase] client and exposes typed query helpers.
///
/// Configuration is supplied at runtime via:
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// The [client] and [auth] getters let the repositories perform PostgREST
/// queries and manage sessions. Until a Supabase project is configured, the
/// repositories fall back to a seeded in-memory store so the app remains
/// fully usable offline/during development.
class SupabaseService {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  bool _initialized = false;

  /// Whether the Supabase project has been configured via --dart-define.
  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  Future<void> init() async {
    if (_initialized) return;
    if (!isConfigured) {
      debugPrint(
        'SupabaseService: not configured. Using local mock store. '
        'Pass --dart-define=SUPABASE_URL and --dart-define=SUPABASE_ANON_KEY '
        'to connect to a real project.',
      );
      _initialized = true;
      return;
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  GoTrueClient get auth {
    return Supabase.instance.client.auth;
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'SupabaseService.init() must be called before using the client.',
      );
    }
    if (!isConfigured) {
      throw StateError(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return Supabase.instance.client;
  }
}
