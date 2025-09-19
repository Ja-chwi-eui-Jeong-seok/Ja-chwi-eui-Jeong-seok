import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ja_chwi/presentation/providers/image_provider.dart';

class ProfileHeaderIndicator extends ConsumerWidget {
  final List<String> images = [
    // 'assets/images/sample1.png',
    // 'assets/images/sample2.png',
    // 'assets/images/sample3.png',
  ];

  ProfileHeaderIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(selectedImageProvider);
    final currentIndex = images.indexOf(selectedImage);

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1️⃣ CircularPercentIndicator
        CircularPercentIndicator(
          radius: 130,
          lineWidth: 20 ,
          percent: (currentIndex + 1) / images.length,
          progressColor: Colors.red,
          backgroundColor: Colors.grey[300]!,
          animation: true,
          animationDuration: 800,
          circularStrokeCap: CircularStrokeCap.round,
        ),

        // 2️⃣ 중앙 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 130,
              height: 130,
              child: Image.asset(
                selectedImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // 3️⃣ 상단 레벨 텍스트
        Positioned(
          top: 0, // 상단에 위치
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Lv. 5', // 예시 레벨
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
