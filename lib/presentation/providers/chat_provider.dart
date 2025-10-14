import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/datasources/gemini_datasource_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/usecases/send_chat_message.dart';
import '../../domain/usecases/generate_recipe.dart';
import '../../domain/usecases/get_user_messages.dart';
import '../../domain/entities/chat_message.dart';

/// Firebase Firestore 인스턴스 Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Gemini DataSource Provider
final geminiDataSourceProvider = Provider<GeminiDataSourceImpl>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return GeminiDataSourceImpl(apiKey);
});

/// ChatRepository Provider
final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ChatRepositoryImpl(firestore);
});

/// SendChatMessage UseCase Provider
final sendChatMessageProvider = Provider<SendChatMessage>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final geminiDataSource = ref.watch(geminiDataSourceProvider);
  return SendChatMessage(chatRepository, geminiDataSource);
});

/// GenerateRecipe UseCase Provider
final generateRecipeProvider = Provider<GenerateRecipe>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final geminiDataSource = ref.watch(geminiDataSourceProvider);
  return GenerateRecipe(chatRepository, geminiDataSource);
});

/// GetUserMessages UseCase Provider
final getUserMessagesProvider = Provider<GetUserMessages>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return GetUserMessages(chatRepository);
});

/// 채팅 메시지 상태 관리 Provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      final getUserMessages = ref.watch(getUserMessagesProvider);
      final sendChatMessage = ref.watch(sendChatMessageProvider);
      final generateRecipe = ref.watch(generateRecipeProvider);

      return ChatMessagesNotifier(
        ref,
        getUserMessages,
        sendChatMessage,
        generateRecipe,
      );
    });

/// AI 타이핑 인디케이터 상태
final aiTypingProvider = StateProvider<bool>((ref) => false);

/// 채팅 메시지 상태 관리 Notifier
class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final GetUserMessages _getUserMessages;
  final SendChatMessage _sendChatMessage;
  final GenerateRecipe _generateRecipe;

  ChatMessagesNotifier(
    this._ref,
    this._getUserMessages,
    this._sendChatMessage,
    this._generateRecipe,
  ) : super([]);

  /// 사용자 ID: FirebaseAuth에서 현재 로그인 UID 사용
  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  /// 메시지 로딩
  Future<void> loadMessages() async {
    try {
      final messages = await _getUserMessages.call(_currentUserId);
      // 정렬: 오래된 -> 최신 (reverse ListView에 안정적)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      state = messages;

      // 오늘 첫 입장: lastGreetedAt이 오늘과 다르면 인삿말 추가
      final meta = await _ref
          .read(chatRepositoryProvider)
          .getChatMetadata(_currentUserId);
      DateTime? lastGreetedAt;
      if (meta != null && meta['lastGreetedAt'] != null) {
        final ts = meta['lastGreetedAt'];
        if (ts is Timestamp) {
          lastGreetedAt = ts.toDate();
        } else if (ts is String) {
          // 혹시 문자열로 저장된 경우 대비
          lastGreetedAt = DateTime.tryParse(ts);
        }
      }

      String toYmd(DateTime d) =>
          '${d.toLocal().year.toString().padLeft(4, '0')}-${d.toLocal().month.toString().padLeft(2, '0')}-${d.toLocal().day.toString().padLeft(2, '0')}';
      final todayYmd = toYmd(DateTime.now());
      final lastYmd = lastGreetedAt != null ? toYmd(lastGreetedAt) : null;

      final isFirstEnterToday = lastYmd != todayYmd;
      if (isFirstEnterToday) {
        // 1) 인삿말 생성
        final greeting = await _ref
            .read(geminiDataSourceProvider)
            .generateGreeting();
        // 2) 메시지 저장
        final hello = ChatMessage(
          role: 'assistant',
          content: greeting,
          timestamp: DateTime.now(),
        );
        await _ref
            .read(chatRepositoryProvider)
            .saveMessage(_currentUserId, hello);
        // 3) 메타데이터 lastGreetedAt 업데이트
        await _ref
            .read(firestoreProvider)
            .collection('chatbot')
            .doc(_currentUserId)
            .set(
              {
                'lastGreetedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
        // 4) 다시 로딩
        final refreshed = await _getUserMessages.call(_currentUserId);
        refreshed.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        state = refreshed;
      }
    } catch (e) {
      // 에러 처리
      if (kDebugMode) {
        print('메시지 로딩 실패: $e');
      }
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String message) async {
    try {
      // 1) 낙관적 UI: 사용자 메시지 즉시 표시
      final tempUser = ChatMessage(
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      );
      state = [...state, tempUser];

      // 2) AI 타이핑 시작
      _ref.read(aiTypingProvider.notifier).state = true;

      // 3) 실제 처리
      await _sendChatMessage.call(_currentUserId, message);

      // 4) 서버 상태로 동기화 (중복 제거 효과)
      await loadMessages();
    } catch (e) {
      // 에러 처리
      if (kDebugMode) {
        print('메시지 전송 실패: $e');
      }
    } finally {
      // 5) 타이핑 종료 (성공/실패 무관)
      _ref.read(aiTypingProvider.notifier).state = false;
    }
  }

  /// 레시피 생성
  Future<void> generateRecipe(List<String> ingredients) async {
    try {
      // 1) 사용자 입력 형태로 먼저 남김 (요청 로그용)
      final tempUser = ChatMessage(
        role: 'user',
        content: '재료: ${ingredients.join(', ')}',
        timestamp: DateTime.now(),
      );
      state = [...state, tempUser];

      _ref.read(aiTypingProvider.notifier).state = true;

      await _generateRecipe.call(_currentUserId, ingredients);
      await loadMessages();
    } catch (e) {
      // 에러 처리
      if (kDebugMode) {
        print('레시피 생성 실패: $e');
      }
    } finally {
      _ref.read(aiTypingProvider.notifier).state = false;
    }
  }

  /// 채팅 초기화
  void clearMessages() {
    state = [];
  }
}
