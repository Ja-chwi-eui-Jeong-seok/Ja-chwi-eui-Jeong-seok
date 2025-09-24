import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';

class HomeCard extends ConsumerWidget {
  const HomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMissionAsync = ref.watch(todayMissionProvider);

    return todayMissionAsync.when(
      data: (mission) => Card(
        color: const Color(0xFFD9D9D9),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            right: 10,
            left: 15,
          ), // 카드 내부 전체 패딩
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 미션',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      mission.missiontitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (mission.tags.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mission.tags.first,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    GoRouter.of(context).go('/mission');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '미션하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(8, 0),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF8F8F8F),
                                size: 12,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF666666),
                                size: 12,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF342E37),
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          height: 110,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          height: 110,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            '미션을 불러올 수 없습니다.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
