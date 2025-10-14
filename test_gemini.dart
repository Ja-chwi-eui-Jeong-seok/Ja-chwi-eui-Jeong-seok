import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/data/datasources/gemini_datasource_impl.dart';

/// Gemini API 테스트 파일
///
/// 이 파일을 실행하여 Gemini API가 제대로 작동하는지 확인합니다.
///
/// 실행 방법:
/// dart test_gemini.dart
void main() async {
  print('🚀 Gemini API 테스트 시작...\n');

  try {
    // 1. 환경 변수 로드
    await dotenv.load(fileName: "assets/config/env/setting.env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print('❌ GEMINI_API_KEY가 설정되지 않았습니다.');
      print('assets/config/env/setting.env 파일에 API 키를 설정해주세요.');
      return;
    }

    print('✅ API 키 로드 완료');

    // 2. Gemini DataSource 초기화
    final geminiDataSource = GeminiDataSourceImpl(apiKey);
    print('✅ Gemini DataSource 초기화 완료\n');

    // 3. 인삿말 테스트
    print('📝 테스트 1: 인삿말 생성');
    final greeting = await geminiDataSource.generateGreeting();
    print('AI 인삿말:');
    print(greeting);
    print('\n' + '=' * 50 + '\n');

    // 4. 일반 메시지 테스트
    print('📝 테스트 2: 일반 메시지 전송');
    final history = <Map<String, String>>[];
    final response = await geminiDataSource.sendMessage(
      '안녕하세요! 자취생인데 요리 초보예요.',
      history,
    );
    print('사용자: 안녕하세요! 자취생인데 요리 초보예요.');
    print('AI 응답:');
    print(response);
    print('\n' + '=' * 50 + '\n');

    // 5. 레시피 생성 테스트 (자연스러운 입력)
    print('📝 테스트 3: 레시피 생성 (자연스러운 입력)');
    final recipeHistory = [
      {'role': 'user', 'content': '안녕하세요! 자취생인데 요리 초보예요.'},
      {'role': 'assistant', 'content': response},
    ];

    final recipe = await geminiDataSource.generateRecipe(
      ['당근하고 호박, 그리고 라면이 있는것같아'],
      recipeHistory,
    );
    print('사용자: 당근하고 호박, 그리고 라면이 있는것같아');
    print('AI 레시피:');
    print(recipe);
    print('\n' + '=' * 50 + '\n');

    // 6. 레시피 생성 테스트 (명확한 입력)
    print('📝 테스트 4: 레시피 생성 (명확한 입력)');
    final recipe2 = await geminiDataSource.generateRecipe(
      ['계란', '양파', '당근', '밥'],
      recipeHistory,
    );
    print('사용자: 계란, 양파, 당근, 밥');
    print('AI 레시피:');
    print(recipe2);

    print('\n🎉 모든 테스트 완료!');
  } catch (e) {
    print('❌ 테스트 실패: $e');
    print('\n🔧 문제 해결 방법:');
    print('1. GEMINI_API_KEY가 올바른지 확인');
    print('2. 인터넷 연결 상태 확인');
    print('3. API 할당량 확인');
  }
}
