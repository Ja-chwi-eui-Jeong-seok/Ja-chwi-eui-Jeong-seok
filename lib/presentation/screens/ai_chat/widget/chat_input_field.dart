import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSend;
  final Future<void> Function(List<String>)? onGenerateRecipe;

  const ChatInputField({
    super.key,
    required this.onSend,
    this.onGenerateRecipe,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text); // 부모에게 전달
    _controller.clear(); // 입력창 비우기
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            // 🍳 레시피 추천 아이콘 (옵션)
            if (widget.onGenerateRecipe != null)
              IconButton(
                tooltip: '재료로 레시피 추천',
                icon: const Icon(Icons.restaurant_menu),
                onPressed: () async {
                  final ingredients = await showModalBottomSheet<List<String>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const _IngredientPickerSheet(),
                  );
                  if (!mounted) return;
                  if (ingredients != null && ingredients.isNotEmpty) {
                    await widget.onGenerateRecipe!(ingredients);
                  }
                },
              ),

            // 💬 텍스트 필드 + 전송 버튼
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // 입력창
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: '메시지를 입력하세요...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                    ),

                    // ✉️ 전송 버튼 (알약 모양)
                    GestureDetector(
                      onTap: _handleSend,
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDA85A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '전송',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientPickerSheet extends StatefulWidget {
  const _IngredientPickerSheet({super.key});

  @override
  State<_IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<_IngredientPickerSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '재료를 쉼표(,)로 구분하여 입력하세요',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '예) 계란, 양파, 당근, 밥',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restaurant),
                  label: const Text('레시피 받기'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final list = _controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    Navigator.of(context).pop(list);
  }
}
