// test/gemini_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../test_helpers/test_config.dart';

void main() {
  group('Gemini API Tests', () {
    test('API Key validation', () async {
      // API 키 유효성 검사
      print('🔍 API Key: ${TestConfig.apiKey}');
      expect(TestConfig.apiKey, isNotEmpty);
      expect(TestConfig.apiKey, startsWith('AIza'));
      print('✅ API Key: ${TestConfig.apiKey.substring(0, 10)}...');
    });

    test('Basic API connection', () async {
      // 기본 API 연결 테스트
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

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      expect(response.statusCode, isNot(equals(401))); // 인증 오류가 아님
    });

    test('Model availability', () async {
      // 모델 사용 가능 여부 확인
      final url = Uri.parse(
        '${TestConfig.baseUrl}/v1beta/models?key=${TestConfig.apiKey}',
      );

      final response = await http.get(url);

      print('📡 Models Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        final modelNames = models.map((m) => m['name']).toList();

        print('📋 Available Models: $modelNames');

        // Gemini 2.0 Flash 모델이 있는지 확인
        final hasGeminiFlash = modelNames.any(
          (name) => name.toString().contains('gemini-2.0-flash'),
        );
        expect(hasGeminiFlash, isTrue);
      }
    });
  });
}
