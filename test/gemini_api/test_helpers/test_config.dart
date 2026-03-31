// test/test_helpers/test_config.dart
class TestConfig {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static String get baseUrl => 'https://generativelanguage.googleapis.com';
  static String get model => 'gemini-2.0-flash';
}
