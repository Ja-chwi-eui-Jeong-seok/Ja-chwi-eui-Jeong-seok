import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/image_provider.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(selectedImageProvider);
    return Stack(
      children: [
        // 1️⃣ FittedBox로 이미지 최대화
        SizedBox(
          width: double.infinity,
          height: 380, // 상단 이미지 영역 높이
          child: Transform.scale(
              scale: 0.5, // 80% 크기
                child: FittedBox(
                  fit: BoxFit.contain,  // 비율 유지하며 최대 영역
                  alignment: Alignment.center,
                  child: Image.asset(
                    selectedImage,
                  ),
                ),
              ),
        ),

        // 2️⃣ 이미지 위 텍스트
        Positioned(
          left: 80,
          bottom: 320,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '집먼지를 선택해 주세요..',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}