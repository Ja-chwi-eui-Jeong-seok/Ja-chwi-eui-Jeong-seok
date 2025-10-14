import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../../data/datasources/gemini_datasource.dart';

/// AI에게 메시지를 전송하는 UseCase
///
/// 사용자가 입력한 메시지를 AI에게 전송하고 응답을 받습니다.
/// - 사용자 메시지 저장
/// - AI 응답 생성
/// - 대화 히스토리 기반 컨텍스트 유지
class SendChatMessage {
  final ChatRepository _chatRepository;
  final GeminiDataSource _geminiDataSource;

  const SendChatMessage(this._chatRepository, this._geminiDataSource);

  /// AI에게 메시지를 전송하고 응답을 받습니다.
  ///
  /// [userId] 사용자 ID
  /// [userMessage] 사용자가 입력한 메시지
  ///
  /// Returns: AI의 응답 메시지
  ///
  /// Throws: [Exception] 메시지 전송 실패 시
  Future<String> call(String userId, String userMessage) async {
    try {
      if (userMessage.trim().isEmpty) {
        throw Exception('메시지를 입력해주세요.');
      }

      // 1. 사용자 메시지 저장
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

      // 4. AI에게 메시지 전송
      final aiResponse = await _geminiDataSource.sendMessage(
        userMessage,
        historyMap,
      );

      // 5. AI 응답 메시지 저장
      final aiChatMessage = ChatMessage(
        role: 'assistant',
        content: aiResponse,
        timestamp: DateTime.now(),
      );

      await _chatRepository.saveMessage(userId, aiChatMessage);

      return aiResponse;
    } catch (e) {
      throw Exception('메시지 전송 실패: $e');
    }
  }
}
