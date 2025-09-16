import 'package:flutter/material.dart';

class DescriptionInputField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: '미션 수행에 대한 간단한 설명을 남겨주세요.',
        border: InputBorder.none,
      ),
    );
  }
}
