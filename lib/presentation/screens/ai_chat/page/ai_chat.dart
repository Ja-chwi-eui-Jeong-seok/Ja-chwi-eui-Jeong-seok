import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/widget/chat_bubble.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/widget/chat_input_field.dart';

class AiChat extends StatelessWidget {
  const AiChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('채팅'),
      ),
      body: Column(
        children: [
          // 채팅 리스트
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChatBubble(
                  isUser: false,
                  message: '안녕하세요! 무엇을 도와드릴까요?',
                  time: '오전 10:12',
                ),
                SizedBox(height: 12),
                ChatBubble(
                  isUser: true,
                  message: '뭘보노',
                  time: '오전 10:13',
                ),
                SizedBox(height: 12),
                ChatBubble(
                  isUser: false,
                  message: '당신의 아름다움에 눈을 둘 곳이 없네요!',
                  time: '오전 10:12',
                ),
                SizedBox(height: 12),
                ChatBubble(
                  isUser: true,
                  message: '이 집 잘하네',
                  time: '오전 10:14',
                  isFailed: true,
                ),
              ],
            ),
          ),

          // 입력창
          const ChatInputField(),
        ],
      ),
    );
  }
}
