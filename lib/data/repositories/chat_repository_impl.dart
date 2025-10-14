import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/chat_message.dart';
import 'package:ja_chwi/domain/repositories/chat_repository.dart';

/// ChatRepository의 Firebase 구현체
///
/// Firebase Firestore를 사용하여 사용자별 채팅 메시지를 관리합니다.
/// - chatbot/{userId}/messages/{messageId} 구조
/// - 메타데이터를 통한 효율적인 관리
class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl(this._firestore);

  // 사용자별 채팅 컬렉션 경로
  CollectionReference get _chatCollection => _firestore.collection('chatbot');

  DocumentReference _userChatDoc(String userId) => _chatCollection.doc(userId);

  CollectionReference _messagesCollection(String userId) =>
      _userChatDoc(userId).collection('messages');

  @override
  Future<void> saveMessage(String userId, ChatMessage message) async {
    try {
      final batch = _firestore.batch();

      // 1. 메시지 저장
      final messageRef = _messagesCollection(userId).doc();
      batch.set(messageRef, message.toJson());

      // 2. 메타데이터 업데이트
      final userDocRef = _userChatDoc(userId);
      batch.set(userDocRef, {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw Exception('메시지 저장 실패: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getRecentMessages(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _messagesCollection(
        userId,
      ).orderBy('timestamp', descending: true).limit(limit).get();

      return snapshot.docs
          .map(
            (doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList()
          .reversed
          .toList(); // 시간순 정렬
    } catch (e) {
      throw Exception('메시지 불러오기 실패: $e');
    }
  }

  @override
  Future<void> cleanupOldMessages(String userId, {int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final oldMessages = await _messagesCollection(
        userId,
      ).where('timestamp', isLessThan: cutoffDate.toIso8601String()).get();

      if (oldMessages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in oldMessages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // 메시지 카운트 업데이트
      await _userChatDoc(userId).update({
        'messageCount': FieldValue.increment(-oldMessages.docs.length),
      });
    } catch (e) {
      throw Exception('오래된 메시지 정리 실패: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getChatMetadata(String userId) async {
    try {
      final doc = await _userChatDoc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('메타데이터 불러오기 실패: $e');
    }
  }
}
