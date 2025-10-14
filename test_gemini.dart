import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/data/datasources/gemini_datasource_impl.dart';

/// Gemini API 테스트 파일
///
/// 이 파일을 실행하여 Gemini API가 제대로 작동하는지 확인합니다.
///
/// 실행 방법:
/// dart test_gemini.dart
void main() async {
  if (kDebugMode) {
    print(' Gemini API 테스트 시작...\n');
  }

  try {
    // 1. 환경 변수 로드
    await dotenv.load(fileName: "assets/config/env/setting.env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      return;
    }

    // 2. Gemini DataSource 초기화
    final geminiDataSource = GeminiDataSourceImpl(apiKey);

    // 3. 인삿말 테스트
    final greeting = await geminiDataSource.generateGreeting();

    // 4. 일반 메시지 테스트
    final history = <Map<String, String>>[];
    final response = await geminiDataSource.sendMessage(
      '안녕하세요! 자취생인데 요리 초보예요.',
      history,
    );

    // 5. 레시피 생성 테스트 (자연스러운 입력)
    final recipeHistory = [
      {'role': 'user', 'content': '안녕하세요! 자취생인데 요리 초보예요.'},
      {'role': 'assistant', 'content': response},
    ];

    final recipe = await geminiDataSource.generateRecipe(
      ['당근하고 호박, 그리고 라면이 있는것같아'],
      recipeHistory,
    );

    // 6. 레시피 생성 테스트 (명확한 입력)
    final recipe2 = await geminiDataSource.generateRecipe(
      ['계란', '양파', '당근', '밥'],
      recipeHistory,
    );
  } catch (e) {}
}
