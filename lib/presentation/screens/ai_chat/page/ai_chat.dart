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

    // 최초 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(chatMessagesProvider.notifier).loadMessages();
      _jumpBottom();
    });
  }

  void _jumpBottom() {
    if (_scroll.hasClients) _scroll.jumpTo(0); // reverse:true 기준 "맨 아래"
  }

  /// 시간 포맷
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
    final messages = ref.watch(chatMessagesProvider);
    final aiTyping = ref.watch(aiTypingProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    // 메시지 길이 변동 시 맨 아래로 (build 내 등록)
    ref.listen<List<dynamic>>(chatMessagesProvider, (prev, next) {
      if (prev == null || next.length != prev.length) {
        _jumpBottom();
      }
    });

    // AI 타이핑 상태 변화에도 하단 유지
    ref.listen<bool>(aiTypingProvider, (_, __) => _jumpBottom());

    //

    // Future<void> _handleDelete(Map<String, dynamic> message) async {
    //   try {
    //     final firestore = FirebaseFirestore.instance;
    //     if (message['id'] != null) {
    //       await firestore.collection('messages').doc(message['id']).delete();
    //       debugPrint('🗑️ 메시지 삭제 완료');
    //     }
    //   } catch (e) {
    //     debugPrint('⚠️ 메시지 삭제 실패: $e');
    //   }
    // }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('채팅'),
      ),
      body: ListView.builder(
        controller: _scroll,
        reverse: true, // 최신이 화면 하단
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: messages.length + (aiTyping ? 1 : 0),
        itemBuilder: (context, i) {
          // reverse:true 이므로 0번이 "맨 아래"
          if (aiTyping && i == 0) return const _AiTypingBubble();

          final idx = aiTyping ? i - 1 : i;
          final msg = messages[(messages.length - 1) - idx];
          final isUser = msg.role.trim().toLowerCase() == 'user';

          final childKey = ValueKey(
            '${msg.timestamp.toIso8601String()}_${msg.role.hashCode}',
          );

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final offsetTween = Tween<Offset>(
                begin: const Offset(0, 0.1), // 아래에서 살짝 올라오는 느낌
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut));

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(offsetTween),
                  child: child,
                ),
              );
            },
            child: Padding(
              key: childKey,
              padding: const EdgeInsets.only(bottom: 12),
              child: ChatBubble(
                key: childKey,
                isUser: isUser,
                message: msg.content,
                time: _formatTime(msg.timestamp),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottom),
        child: SafeArea(
          top: false,
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
