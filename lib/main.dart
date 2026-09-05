import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/services/app_data.dart';
import 'data/services/auth_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/supabase_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/onboarding/splash_screen.dart';

late final SupabaseService supabaseService;
late final AuthService authService;
late final StorageService storageService;
late final AppData appData;
late final NotificationService notificationService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  supabaseService = SupabaseService();
  storageService = const StorageService();
  appData = AppData(supabase: supabaseService);
  notificationService = NotificationService();
  authService = AuthService(
    supabase: supabaseService,
    storage: storageService,
    appData: appData,
  );

  await supabaseService.init();
  await authService.restoreSession();
  await notificationService.init();

  runApp(const CreneauMedeaApp());
}

class CreneauMedeaApp extends StatelessWidget {
  const CreneauMedeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Créneau Médéa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: authService.isAuthenticated
          ? const MainShell()
          : const SplashScreen(),
    );
  }
}
