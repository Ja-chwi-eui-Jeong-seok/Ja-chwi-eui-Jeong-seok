import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/go_to_completed_button.dart';

class ProfileSection extends ConsumerWidget {
  final bool showButton;

  const ProfileSection({
    super.key,
    this.showButton = true, // 기본값은 true로 설정하여 기존 화면에 영향이 없도록 함
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: ClipOval(
                child: Image(
                  image:
                      (userProfile.imageFullUrl.startsWith('http')
                              ? NetworkImage(userProfile.imageFullUrl)
                              : AssetImage(userProfile.imageFullUrl))
                          as ImageProvider,
                  fit: BoxFit.contain, // 이미지가 잘리지 않고 원 안에 모두 보이도록 설정
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userProfile.level, style: const TextStyle(fontSize: 16)),
                  Text(
                    userProfile.nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (showButton) const GoToCompletedButton(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('프로필 정보를 불러오지 못했습니다: $error')),
    );
  }
}
