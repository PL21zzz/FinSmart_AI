import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get geminiApiKey {
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }
}
