import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/connectivity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env – file is optional; silences errors if missing.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  runApp(const ProviderScope(child: SafeRouteApp()));
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
