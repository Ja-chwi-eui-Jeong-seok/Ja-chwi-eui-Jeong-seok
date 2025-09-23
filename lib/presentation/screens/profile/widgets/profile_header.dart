import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/image_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final int step; // ✅ step 파라미터 추가

  const ProfileHeader({super.key, required this.step});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(selectedImageProvider);
    return Stack(
      children: [
        // 1️⃣ FittedBox로 이미지 최대화
        SizedBox(
          width: double.infinity,
          height: 300, // 상단 이미지 영역 높이
          child: Transform.scale(
              scale: 0.6, // 80% 크기
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
          bottom: 250,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
             child: Text(
                // Replace 'step' with your actual step variable or logic
                (() {
                  // You need to define 'step' somewhere above, e.g., final step = ...;
                  if (step == 0) {
                    return '집먼지 이름을 입력해주세요';
                  } else if (step == 1) {
                    return '집먼지를 꾸며주세요';
                  } else {
                    return '집먼지의 집을 찾아주세요';
                  }
                })(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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