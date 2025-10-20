import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/triple_arrow_icon.dart';
import 'package:ja_chwi/presentation/providers/mission_providers.dart';

//
class HomeCard extends ConsumerWidget {
  final Map<String, dynamic>? extra;
  const HomeCard({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMissionAsync = ref.watch(todayMissionProvider);

    return todayMissionAsync.when(
      data: (mission) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white, // 밝은 베이지톤
                Color(0xFFF5CFA3), // 오렌지 포인트
              ],
            ),
          ),
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
                          color: Colors.black, // 그라데이션 위에서 잘 보이게 색상 변경
                        ),
                      ),
                      Text(
                        mission.missiontitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // 텍스트 색상 조정
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
                    onPressed: () => context.push(
                      '/mission-create',
                      extra: mission.missiontitle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            '미션하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFED8B5A),
                            ),
                          ),
                          SizedBox(height: 4),
                          TripleArrowIcon(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
