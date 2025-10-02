import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionAchieversScreen extends ConsumerStatefulWidget {
  const MissionAchieversScreen({super.key});

  @override
  ConsumerState<MissionAchieversScreen> createState() =>
      MissionAchieversScreenState();
}

class MissionAchieversScreenState
    extends ConsumerState<MissionAchieversScreen> {
  bool _showAllAchievers = false;

  @override
  Widget build(BuildContext context) {
    final achieversAsync = ref.watch(weeklyAchieversProvider);

    return Scaffold(
      appBar: CommonAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          RefreshIconButton(
            onPressed: () => ref.invalidate(weeklyAchieversProvider),
          ),
        ],
      ),
      body: achieversAsync.when(
        data: (achievers) {
          final selectedWeek = ref.watch(selectedWeekProvider);
          final startOfWeek = selectedWeek.subtract(
            Duration(days: selectedWeek.weekday - 1),
          );
          final endOfWeek = startOfWeek.add(const Duration(days: 6));

          final weekString =
              '${DateFormat('yyyy년 MM월 dd일').format(startOfWeek)} ~ ${DateFormat('MM월 dd일').format(endOfWeek)}';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      onPressed: () {
                        ref.read(selectedWeekProvider.notifier).state =
                            selectedWeek.subtract(const Duration(days: 7));
                      },
                    ),
                    const SizedBox(width: 20),
                    Text(
                      weekString,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        ref.read(selectedWeekProvider.notifier).state =
                            selectedWeek.add(const Duration(days: 7));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRankingSection(achievers),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          // 1, 2, 3위는 상단에 표시되므로 4위부터 리스트에 표시합니다.
                          itemCount: _getListItemCount(achievers.length),
                          itemBuilder: (context, index) {
                            // index는 0부터 시작하므로, 4위(achievers[3])부터 가져옵니다.
                            final rank = index + 4;
                            final achiever = achievers[rank - 1];
                            // AchieverCard 대신 ListTile과 유사한 UI를 직접 구성합니다.
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '$rank',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: ClipOval(
                                      child: Image(
                                        image:
                                            (achiever.imageFullUrl.startsWith(
                                                      'http',
                                                    )
                                                    ? NetworkImage(
                                                        achiever.imageFullUrl,
                                                      )
                                                    : AssetImage(
                                                        achiever.imageFullUrl,
                                                      ))
                                                as ImageProvider,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 30,
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    achiever.level,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    achiever.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${achiever.weekCount}회',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      // achiever.userId를 사용하여 uid를 가져옵니다.
                                      context.push(
                                        '/profile-detail',
                                        extra: {'userId': achiever.userId},
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          '상세보기',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.black,
                                          size: 13,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                        ),
                        if (achievers.length > 10 && !_showAllAchievers)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllAchievers = true;
                                });
                              },
                              child: const Text(
                                '더보기',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $error')),
      ),
    );
  }

  int _getListItemCount(int totalAchievers) {
    if (totalAchievers <= 3) return 0;
    final remaining = totalAchievers - 3;
    if (totalAchievers > 10 && !_showAllAchievers) {
      return 7; // 4위부터 10위까지 (7명)
    }
    return remaining; // 전체
  }

  Widget _buildRankingSection(List<MissionAchiever> achievers) {
    final _placeholderAchiever = MissionAchiever(
      userId: '',
      name: '미정',
      level: 'Lv.?',
      missionCount: 0,
      weekCount: 0,
      imageFullUrl: 'assets/images/profile/black.png', // 기본 이미지
    );

    // 1, 2, 3위 데이터 준비 (실제 데이터가 없으면 플레이스홀더 사용)
    final List<Map<String, dynamic>> rankerData = [
      {
        'rank': 1,
        'data': achievers.length > 0 ? achievers[0] : _placeholderAchiever,
        'size': 100.0,
        'isFirst': true,
      },
      {
        'rank': 2,
        'data': achievers.length > 1 ? achievers[1] : _placeholderAchiever,
        'size': 80.0,
        'isFirst': false,
      },
      {
        'rank': 3,
        'data': achievers.length > 2 ? achievers[2] : _placeholderAchiever,
        'size': 80.0,
        'isFirst': false,
      },
    ];

    // UI 레이아웃 순서(2위, 1위, 3위)에 맞게 데이터를 재구성합니다.
    final topRankersInLayoutOrder = [
      rankerData[1], // 2위
      rankerData[0], // 1위
      rankerData[2], // 3위
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: topRankersInLayoutOrder.map((ranker) {
        final isFirst = ranker['isFirst'] as bool;
        final MissionAchiever achiever = ranker['data'] as MissionAchiever;
        return Flexible(
          flex: isFirst ? 3 : 2,
          child: _buildRanker(
            ranker['rank'] as int,
            achiever,
            ranker['size'] as double,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRanker(int rank, MissionAchiever achiever, double circleSize) {
    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = Colors.amber; // Gold
        break;
      case 2:
        medalColor = Colors.grey.shade400; // Silver
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        medalColor = Colors.transparent;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: circleSize * 1.2,
              height: circleSize * 1.2,
              child: ClipOval(
                child: Image(
                  image:
                      (achiever.imageFullUrl.startsWith('http')
                              ? NetworkImage(achiever.imageFullUrl)
                              : AssetImage(achiever.imageFullUrl))
                          as ImageProvider,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person_outline,
                      size: circleSize * 0.6,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -4,
              left: -4,
              child: Container(
                width: circleSize * 0.38,
                height: circleSize * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: medalColor,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: circleSize * 0.18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          achiever.level,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          achiever.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${achiever.weekCount}회',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
