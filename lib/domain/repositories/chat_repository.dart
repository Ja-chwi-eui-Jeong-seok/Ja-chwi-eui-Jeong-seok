import '../entities/chat_message.dart';

/// AI 채팅을 위한 Repository 인터페이스
///
/// Firebase Firestore를 사용하여 사용자별 채팅 메시지를 관리합니다.
/// - 메시지 저장/불러오기
/// - 최근 메시지만 로딩 (성능 최적화)
/// - 오래된 메시지 정리
abstract interface class ChatRepository {
  /// 새 메시지를 저장합니다.
  ///
  /// [userId] 사용자 ID
  /// [message] 저장할 메시지
  Future<void> saveMessage(String userId, ChatMessage message);

  /// 사용자의 최근 메시지들을 불러옵니다.
  ///
  /// [userId] 사용자 ID
  /// [limit] 불러올 메시지 개수 (기본값: 50)
  ///
  /// Returns: 최근 메시지 목록 (시간순)
  Future<List<ChatMessage>> getRecentMessages(String userId, {int limit = 50});

  /// 오래된 메시지들을 정리합니다.
  ///
  /// [userId] 사용자 ID
  /// [daysToKeep] 보관할 일수 (기본값: 30일)
  Future<void> cleanupOldMessages(String userId, {int daysToKeep = 30});

  /// 사용자의 채팅 메타데이터를 가져옵니다.
  ///
  /// [userId] 사용자 ID
  ///
  /// Returns: 메타데이터 (마지막 메시지 시간, 메시지 개수 등)
  Future<Map<String, dynamic>?> getChatMetadata(String userId);
}
