import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';

class NicknameInput extends ConsumerStatefulWidget {
  final Future<void> Function(String)? onNext;

  const NicknameInput({super.key, this.onNext});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  void _handleNext() async {
    final input = _controller.text.trim();
    final sanitized = XssFilter.sanitize(input);

    if (sanitized.isEmpty) {
      setState(() => errorText = "닉네임을 입력해주세요");
      return;
    }

    // 금지어 체크
    final bannedResult = XssFilter.secureInput(sanitized);
    if (bannedResult['hasBannedWord'] == true) {
      setState(() => errorText =
          "사용할 수 없는 단어가 포함되어 있습니다: ${bannedResult['matchedWords'].join(', ')}");
      return;
    }

    setState(() => errorText = null);

    if (widget.onNext != null) {
      await widget.onNext!(sanitized); // 다음 단계 호출
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: '집먼지의 이름을 지어주세요!',
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _handleNext,
          child: const Text("다음"),
        ),
      ],
    );
  }
}
