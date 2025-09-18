import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/category_tabs.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/achiever_card.dart';
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
        actions: [RefreshIconButton(onPressed: () {})],
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
              child: ListView.separated(
                itemCount: achievers.length,
                itemBuilder: (context, index) {
                  final achiever = achievers[index];
                  return AchieverCard(
                    level: achiever.level,
                    name: achiever.name,
                    time: achiever.time,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection(List<MissionAchiever> mockAllAchievers) {
    // TODO: 실제 랭킹 데이터는 상태관리(Provider, BLoC 등)를 통해 가져와야 합니다.
    // UI 레이아웃 순서(2위, 1위, 3위)에 맞게 데이터를 재구성합니다.
    // 데이터가 3개 미만일 경우 에러 방지
    if (mockAllAchievers.length < 3) return const SizedBox.shrink();
    final topRankers = [
      {
        'rank': 2,
        'name': mockAllAchievers[1].name,
        'level': mockAllAchievers[1].level,
        'size': 80.0,
        'isFirst': false,
      },
      {
        'rank': 1,
        'name': mockAllAchievers[0].name,
        'level': mockAllAchievers[0].level,
        'size': 100.0,
        'isFirst': true,
      },
      {
        'rank': 3,
        'name': mockAllAchievers[2].name,
        'level': mockAllAchievers[2].level,
        'size': 80.0,
        'isFirst': false,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: topRankers.map((ranker) {
        final isFirst = ranker['isFirst'] as bool;
        return Flexible(
          flex: isFirst ? 3 : 2,
          child: _buildRanker(
            ranker['rank'] as int,
            ranker['name'] as String,
            ranker['level'] as String,
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
                border: Border.all(color: medalColor, width: 4), // 랭킹 테두리 색
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
