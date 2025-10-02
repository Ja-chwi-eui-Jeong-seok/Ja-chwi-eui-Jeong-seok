import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/widget/chat_bubble.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/widget/chat_input_field.dart';

class AiChat extends StatefulWidget {
  const AiChat({super.key});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  /// GPT 호출
  Future<void> _sendToGPT(String userMessage) async {
    final now = TimeOfDay.now().format(context);

    // 사용자 메시지 추가
    setState(() {
      _messages.add({"role": "user", "content": userMessage, "time": now});
    });

    try {
      final response = await OpenAI.instance.chat.create(
        model: "gpt-4.1-mini",
        messages: _messages.map((m) {
          return OpenAIChatCompletionChoiceMessageModel(
            role: m['role'] == 'user'
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                m['contemt'],
              ),
            ],
          );
        }).toList(),
      );

      // 답변 꺼내기 (null-safe)
      final reply =
          response.choices.first.message.content
              ?.map((c) => c.text)
              .join(" ")
              .trim() ??
          "응답 없음";

      final replyTime = TimeOfDay.now().format(context);

      setState(() {
        _messages.add({
          "role": "assistant",
          "content": reply,
          "time": replyTime,
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "⚠️ 오류 발생: $e",
          "time": now,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChatBubble(
                    isUser: msg['role'] == 'user',
                    message: msg['content'],
                    time: msg['time'],
                  ),
                );
              },
            ),
          ),

          // 입력창
          ChatInputField(onSend: _sendToGPT),
        ],
      ),
    );
  }
}
