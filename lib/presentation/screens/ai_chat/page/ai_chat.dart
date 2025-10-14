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
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // 최초 로딩만 수행
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(chatMessagesProvider.notifier).loadMessages();
      _jumpBottom();
    });
  }

  void _jumpBottom() {
    if (_scroll.hasClients) _scroll.jumpTo(0); // reverse:true 기준 "맨 아래"
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final d = now.difference(timestamp);
    if (d.inDays > 0) return '${timestamp.month}/${timestamp.day}';
    if (d.inHours > 0) return '${d.inHours}시간 전';
    if (d.inMinutes > 0) return '${d.inMinutes}분 전';
    return '방금 전';
  }

  @override
  Widget build(BuildContext context) {
    // listen은 build 중에 등록
    ref.listen<List<dynamic>>(chatMessagesProvider, (prev, next) {
      if (prev == null || next.length != prev.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _jumpBottom());
      }
    });
    ref.listen<bool>(aiTypingProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpBottom());
    });

    final messages = ref.watch(chatMessagesProvider);
    final aiTyping = ref.watch(aiTypingProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

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
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: 0),
        child: ListView.builder(
          controller: _scroll,
          reverse: true,
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: messages.length + (aiTyping ? 1 : 0),
          itemBuilder: (context, i) {
            if (aiTyping && i == 0) return const _AiTypingBubble();

            final idx = aiTyping ? i - 1 : i;
            final msg = messages[(messages.length - 1) - idx];
            final isUser = msg.role.trim().toLowerCase() == 'user';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ChatBubble(
                key: ValueKey(
                  '${msg.timestamp.toIso8601String()}_${msg.role.hashCode}',
                ),
                isUser: isUser,
                message: msg.content,
                time: _formatTime(msg.timestamp),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ChatInputField(
              onSend: (text) async {
                await ref.read(chatMessagesProvider.notifier).sendMessage(text);
                _jumpBottom();
              },
              onGenerateRecipe: (ings) async {
                await ref
                    .read(chatMessagesProvider.notifier)
                    .generateRecipe(ings);
                _jumpBottom();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AiTypingBubble extends StatelessWidget {
  const _AiTypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            _Dot(delay: 150),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = ((_c.value + (widget.delay / 900)) % 1.0);
        final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Transform.scale(
            scale: scale,
            child: const CircleAvatar(radius: 3, backgroundColor: Colors.grey),
          ),
        );
      },
    );
  }
}
