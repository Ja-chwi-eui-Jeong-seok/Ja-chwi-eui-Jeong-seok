import 'package:ja_chwi/domain/entities/chat_message.dart';

import '../repositories/chat_repository.dart';
import '../../data/datasources/gemini_datasource.dart';

/// 냉장고 재료를 기반으로 레시피를 생성하는 UseCase
///
/// 사용자가 가진 재료를 입력하면 AI가 맞춤 레시피를 생성합니다.
/// - 재료 기반 레시피 추천
/// - 대화 히스토리 기반 개인화
/// - 자취생 맞춤 조건 적용
class GenerateRecipe {
  final ChatRepository _chatRepository;
  final GeminiDataSource _geminiDataSource;

  const GenerateRecipe(this._chatRepository, this._geminiDataSource);

  /// 냉장고 재료를 기반으로 레시피를 생성합니다.
  ///
  /// [userId] 사용자 ID
  /// [ingredients] 사용자가 가진 재료 리스트
  ///
  /// Returns: AI가 생성한 레시피
  ///
  /// Throws: [Exception] 레시피 생성 실패 시
  Future<String> call(String userId, List<String> ingredients) async {
    try {
      if (ingredients.isEmpty) {
        throw Exception('재료를 입력해주세요.');
      }

      // 재료 리스트 정리 (공백 제거, 중복 제거)
      final cleanIngredients = ingredients
          .map((ingredient) => ingredient.trim())
          .where((ingredient) => ingredient.isNotEmpty)
          .toSet()
          .toList();

      if (cleanIngredients.isEmpty) {
        throw Exception('유효한 재료를 입력해주세요.');
      }

      // 1. 사용자 메시지 저장 (재료 정보)
      final userMessage = '냉장고에 있는 재료: ${cleanIngredients.join(', ')}';
      final userChatMessage = ChatMessage(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      );

      await _chatRepository.saveMessage(userId, userChatMessage);

      // 2. 대화 히스토리 가져오기
      final history = await _chatRepository.getRecentMessages(
        userId,
        limit: 20,
      );

      // 3. 대화 히스토리를 Map 형태로 변환
      final historyMap = history
          .map(
            (msg) => {
              'role': msg.role,
              'content': msg.content,
            },
          )
          .toList();

      // 4. AI에게 레시피 요청
      final recipe = await _geminiDataSource.generateRecipe(
        cleanIngredients,
        historyMap,
      );

      // 5. AI 응답 메시지 저장
      final aiChatMessage = ChatMessage(
        role: 'assistant',
        content: recipe,
        timestamp: DateTime.now(),
      );

      await _chatRepository.saveMessage(userId, aiChatMessage);

      return recipe;
    } catch (e) {
      throw Exception('레시피 생성 실패: $e');
    }
  }
}
