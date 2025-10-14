import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ja_chwi/data/datasources/gemini_datasource_impl.dart';

void main() {
  late GeminiDataSourceImpl dataSource;

  setUpAll(() async {
    await dotenv.load(fileName: "assets/config/env/setting.env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    assert(apiKey != null && apiKey.isNotEmpty, 'GEMINI_API_KEY missing');
    dataSource = GeminiDataSourceImpl(apiKey!);
  });

  group('GeminiDataSourceImpl', () {
    test('generateGreeting returns non-empty text', () async {
      final text = await dataSource.generateGreeting();
      print('greeting:\n$text');
      expect(text.trim(), isNotEmpty);
    });

    test('sendMessage returns response', () async {
      final history = <Map<String, String>>[];
      final res = await dataSource.sendMessage('''돈이없어''', history);
      print('sendMessage:\n$res');
      expect(res.trim(), isNotEmpty);
    });

    test('generateRecipe returns recipe-like text', () async {
      final history = <Map<String, String>>[
        {'role': 'user', 'content': '자취 요리 초보야.'},
      ];
      final ingredients = ['계란이있는것같고', '양파비슷한건가?양파랑', '밥이랑고기랑참기름있어'];
      final res = await dataSource.generateRecipe(ingredients, history);
      print('generateRecipe:\n$res');
      expect(res.trim(), isNotEmpty);
      // 필요하면 형식 일부를 가볍게 점검
      // expect(res, contains('⏰ 조리시간'));
      // expect(res, contains('🥘 재료'));
      // expect(res, contains('👨‍🍳 조리법'));
    });
  });
}
