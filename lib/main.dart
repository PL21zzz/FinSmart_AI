import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/config/env_config.dart';
import 'app/config/app_router.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  try {
    await EnvConfig.init();
    debugPrint('EnvConfig initialized successfully. Gemini Key present: ${EnvConfig.geminiApiKey.isNotEmpty}');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  // Initialize Hive for offline-first caching
  await Hive.initFlutter();

  runApp(const FinSmartApp());
}

class FinSmartApp extends StatelessWidget {
  const FinSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinSmart AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to sleek Dark Mode
      routerConfig: AppRouter.router,
    );
  }
}
