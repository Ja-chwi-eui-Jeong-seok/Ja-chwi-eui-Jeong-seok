import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../test_helpers/test_config.dart';

void main() {
  group('Gemini API Tests', () {
    test('API Key validation', () async {
      if (TestConfig.apiKey.isEmpty) {
        return;
      }

      expect(TestConfig.apiKey, startsWith('AIza'));
    });

    test('Basic API connection', () async {
      if (TestConfig.apiKey.isEmpty) {
        return;
      }

      final url = Uri.parse(
        '${TestConfig.baseUrl}/v1beta/models/${TestConfig.model}:generateContent?key=${TestConfig.apiKey}',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Hello, test message'},
              ],
            },
          ],
        }),
      );

      expect(response.statusCode, isNot(equals(401)));
    });

    test('Model availability', () async {
      if (TestConfig.apiKey.isEmpty) {
        return;
      }

      final url = Uri.parse(
        '${TestConfig.baseUrl}/v1beta/models?key=${TestConfig.apiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        final modelNames = models.map((m) => m['name']).toList();

        final hasGeminiFlash = modelNames.any(
          (name) => name.toString().contains('gemini-2.0-flash'),
        );
        expect(hasGeminiFlash, isTrue);
      }
    });
  });
}
