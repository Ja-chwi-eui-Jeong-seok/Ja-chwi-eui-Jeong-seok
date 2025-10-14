import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// 사용자의 채팅 메시지를 가져오는 UseCase
///
/// 사용자의 최근 대화 메시지들을 불러옵니다.
/// - 최근 메시지만 로딩 (성능 최적화)
/// - 시간순 정렬
class GetUserMessages {
  final ChatRepository _chatRepository;

  const GetUserMessages(this._chatRepository);

  /// 사용자의 최근 메시지들을 가져옵니다.
  ///
  /// [userId] 사용자 ID
  /// [limit] 불러올 메시지 개수 (기본값: 50)
  ///
  /// Returns: 최근 메시지 목록 (시간순)
  ///
  /// Throws: [Exception] 메시지 불러오기 실패 시
  Future<List<ChatMessage>> call(String userId, {int limit = 50}) async {
    try {
      if (userId.isEmpty) {
        throw Exception('사용자 ID가 필요합니다.');
      }

      return await _chatRepository.getRecentMessages(userId, limit: limit);
    } catch (e) {
      throw Exception('메시지 불러오기 실패: $e');
    }
  }
}
