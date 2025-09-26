import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/category_tabs.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/achiever_card.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionAchieversScreen extends ConsumerStatefulWidget {
  const MissionAchieversScreen({super.key});

  @override
  ConsumerState<MissionAchieversScreen> createState() =>
      MissionAchieversScreenState();
}

class MissionAchieversScreenState
    extends ConsumerState<MissionAchieversScreen> {
  // TODO: 실제 미션 데이터는 상태관리(Provider, BLoC 등)를 통해 가져와야 합니다.
  bool _showAllAchievers = false;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['요리', '청소', '운동'];

  @override
  Widget build(BuildContext context) {
    final achievers = ref.watch(achieversProvider);

    return Scaffold(
      appBar: CommonAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          RefreshIconButton(
            onPressed: () => ref.invalidate(achieversProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CategoryTabs(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            ),
            const SizedBox(height: 24),
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
                        final achiever = achievers[index + 3];
                        return AchieverCard(
                          rank: index + 4, // 4, 5, 6... 등수를 전달
                          level: achiever.level,
                          name: achiever.name,
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

  Widget _buildRankingSection(List<MissionAchiever> mockAllAchievers) {
    // TODO: 실제 랭킹 데이터는 상태관리(Provider, BLoC 등)를 통해 가져와야 합니다.
    if (mockAllAchievers.isEmpty) return const SizedBox.shrink();

    final rankerData = List<Map<String, dynamic>?>.filled(3, null);

    // 1, 2, 3위 데이터 채우기
    if (mockAllAchievers.isNotEmpty) {
      rankerData[0] = {
        'rank': 1,
        'data': mockAllAchievers[0],
        'size': 100.0,
        'isFirst': true,
      };
    }
    if (mockAllAchievers.length > 1) {
      rankerData[1] = {
        'rank': 2,
        'data': mockAllAchievers[1],
        'size': 80.0,
        'isFirst': false,
      };
    }
    if (mockAllAchievers.length > 2) {
      rankerData[2] = {
        'rank': 3,
        'data': mockAllAchievers[2],
        'size': 80.0,
        'isFirst': false,
      };
    }

    // UI 레이아웃 순서(2위, 1위, 3위)에 맞게 데이터를 재구성합니다.
    final topRankersInLayoutOrder = [
      rankerData[1], // 2위
      rankerData[0], // 1위
      rankerData[2], // 3위
    ].where((data) => data != null).cast<Map<String, dynamic>>().toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: topRankersInLayoutOrder.map((ranker) {
        final isFirst = ranker['isFirst'] as bool;
        return Flexible(
          flex: isFirst ? 3 : 2,
          child: _buildRanker(
            ranker['rank'] as int,
            (ranker['data'] as MissionAchiever).name,
            (ranker['data'] as MissionAchiever).level,
            ranker['size'] as double,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRanker(int rank, String name, String level, double circleSize) {
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
            Container(
              width: circleSize * 1.2,
              height: circleSize * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                // border: Border.all(color: medalColor, width: 4), // 랭킹 테두리 색
              ),
              child: Icon(
                Icons.person_outline,
                size: circleSize * 0.6,
                color: Colors.grey[600],
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
        Text(level, style: const TextStyle(fontSize: 12, color: Colors.black)),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
