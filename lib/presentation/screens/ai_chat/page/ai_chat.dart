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
  @override
  void initState() {
    super.initState();
    // 메시지 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider.notifier).loadMessages();
    });
  }

  /// Gemini AI 호출
  Future<void> _sendToGemini(String userMessage) async {
    try {
      await ref.read(chatMessagesProvider.notifier).sendMessage(userMessage);
    } catch (e) {
      // 에러는 이미 ChatMessagesNotifier에서 처리됨
      print('메시지 전송 실패: $e');
    }
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('채팅'),
      ),
      body: Column(
        children: [
          // 채팅 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChatBubble(
                    isUser: msg.role == 'user',
                    message: msg.content,
                    time: _formatTime(msg.timestamp),
                  ),
                );
              },
            ),
          ),

          // 입력창
          ChatInputField(onSend: _sendToGemini),
        ],
      ),
    );
  }
}
