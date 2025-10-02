import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';

class SelectedPreview extends ConsumerWidget {
  const SelectedPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(nicknameProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    
    if (selectedImage == null) return const Text("프로필 이미지를 선택하세요");
if (nickname == null || nickname.isEmpty) return const Text("닉네임을 입력하세요");
    return Column(
      children: [
        Text("닉네임: $nickname"),
        const SizedBox(height: 8),
        Image.asset(selectedImage.fullUrl, width: 80, height: 80),
      ],
    );
  }
}