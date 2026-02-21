import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/connectivity_provider.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  // Catch all uncaught Flutter errors so the app never shows a blank screen.
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load .env – file is optional; silences errors if missing.
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}

    // Initialize Firebase with platform-specific options
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');

      // Seed initial Firestore data if collections are empty.
      try {
        final firebaseSvc = FirebaseService.instance;
        await firebaseSvc.seedAnalyticsIfNeeded();
        await firebaseSvc.seedAlertsIfNeeded();
      } catch (e) {
        debugPrint('Firestore seeding skipped: $e');
      }
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }

    runApp(const ProviderScope(child: SafeRouteApp()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
  });
}

class SafeRouteApp extends ConsumerStatefulWidget {
  const SafeRouteApp({super.key});

  @override
  ConsumerState<SafeRouteApp> createState() => _SafeRouteAppState();
}

class _SafeRouteAppState extends ConsumerState<SafeRouteApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SafeRoute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isOnline = ref.watch(connectivityProvider);
        return Column(
          children: [
            if (!isOnline)
              Material(
                child: Container(
                  width: double.infinity,
                  color: Colors.red.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: const SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'No internet connection',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}
