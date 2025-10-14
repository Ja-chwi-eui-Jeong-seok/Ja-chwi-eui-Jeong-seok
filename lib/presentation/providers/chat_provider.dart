import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/gemini_datasource_impl.dart';
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
  final apiKey = 'AIzaSyBeBjchVMG4HW1vlB-csYepfWmv7khLbdc'; // TODO: 환경변수에서 가져오기
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
        getUserMessages,
        sendChatMessage,
        generateRecipe,
      );
    });

/// 채팅 메시지 상태 관리 Notifier
class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final GetUserMessages _getUserMessages;
  final SendChatMessage _sendChatMessage;
  final GenerateRecipe _generateRecipe;

  ChatMessagesNotifier(
    this._getUserMessages,
    this._sendChatMessage,
    this._generateRecipe,
  ) : super([]);

  /// 사용자 ID (현재는 하드코딩, 나중에 Auth에서 가져오기)
  String get _currentUserId => 'user_123'; // TODO: 실제 사용자 ID로 변경

  /// 메시지 로딩
  Future<void> loadMessages() async {
    try {
      final messages = await _getUserMessages.call(_currentUserId);
      state = messages;
    } catch (e) {
      // 에러 처리
      print('메시지 로딩 실패: $e');
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String message) async {
    try {
      final response = await _sendChatMessage.call(_currentUserId, message);
      // 메시지가 이미 저장되었으므로 다시 로딩
      await loadMessages();
    } catch (e) {
      // 에러 처리
      print('메시지 전송 실패: $e');
    }
  }

  /// 레시피 생성
  Future<void> generateRecipe(List<String> ingredients) async {
    try {
      final recipe = await _generateRecipe.call(_currentUserId, ingredients);
      // 메시지가 이미 저장되었으므로 다시 로딩
      await loadMessages();
    } catch (e) {
      // 에러 처리
      print('레시피 생성 실패: $e');
    }
  }

  /// 채팅 초기화
  void clearMessages() {
    state = [];
  }
}
