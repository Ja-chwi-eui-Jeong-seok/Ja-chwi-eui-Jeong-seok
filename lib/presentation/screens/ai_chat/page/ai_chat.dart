import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/widget/chat_bubble.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/widget/chat_input_field.dart';
import 'package:ja_chwi/presentation/providers/chat_provider.dart';

class AiChat extends ConsumerStatefulWidget {
  const AiChat({super.key});

  @override
  ConsumerState<AiChat> createState() => _AiChatState();
}

class _AiChatState extends ConsumerState<AiChat> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // 메시지 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider.notifier).loadMessages();
      _scrollToBottom();
    });
  }

  /// Gemini AI 호출
  Future<void> _sendToGemini(String userMessage) async {
    try {
      await ref.read(chatMessagesProvider.notifier).sendMessage(userMessage);
      _scrollToBottom();
    } catch (e) {
      // 에러는 이미 ChatMessagesNotifier에서 처리됨
      print('메시지 전송 실패: $e');
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// 시간 포맷팅
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.month}/${timestamp.day}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // 메시지 목록 변동 시 자동 스크롤 (build 내부에서 등록 필요)
    ref.listen<List<dynamic>>(chatMessagesProvider, (prev, next) {
      if (prev == null || next.length != prev.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('채팅'),
      ),
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            // 채팅 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.role.trim().toLowerCase() == 'user';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChatBubble(
                      isUser: isUser,
                      message: msg.content,
                      time: _formatTime(msg.timestamp),
                    ),
                  );
                },
              ),
            ),

            // 입력창 + 레시피 호출 연결
            ChatInputField(
              onSend: _sendToGemini,
              onGenerateRecipe: (ingredients) async {
                await ref
                    .read(chatMessagesProvider.notifier)
                    .generateRecipe(ingredients);
                _scrollToBottom();
              },
            ),
          ],
        ),
      ),
    );
  }
}
