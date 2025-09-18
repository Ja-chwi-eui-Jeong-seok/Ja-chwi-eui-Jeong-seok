import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/achievers_list.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/category_tabs.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionAchieversScreen extends StatefulWidget {
  const MissionAchieversScreen({super.key});

  @override
  State<MissionAchieversScreen> createState() => MissionAchieversScreenState();
}

class MissionAchieversScreenState extends State<MissionAchieversScreen> {
  // TODO: 실제 미션 데이터는 상태관리(Provider, BLoC 등)를 통해 가져와야 합니다.
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['요리', '청소', '운동'];

  final List<Map<String, String>> _allAchievers = [
    {'name': '집인데 집가고 싶다님', 'time': '08:12 완료'},
    {'name': '아니 아님', 'time': '09:12 완료'},
    {'name': '뿌뿌로', 'time': '10:12 완료'},
    {'name': '네번째 달성자', 'time': '11:00 완료'},
    {'name': '다섯번째 달성자', 'time': '12:00 완료'},
    {'name': '여섯번째 달성자', 'time': '13:00 완료'},
  ];

  @override
  Widget build(BuildContext context) {
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
            _buildRankingSection(),
            const SizedBox(height: 24),
            Expanded(child: AchieversList(achievers: _allAchievers)),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection() {
    // TODO: 실제 랭킹 데이터는 상태관리(Provider, BLoC 등)를 통해 가져와야 합니다.
    final topRankers = [
      {
        'rank': 2,
        'name': '아니 아님',
        'level': 'Lv.15',
        'size': 80.0,
        'isFirst': false,
      },
      {
        'rank': 1,
        'name': '집인데 집가고 싶다님',
        'level': 'Lv.20',
        'size': 100.0,
        'isFirst': true,
      },
      {
        'rank': 3,
        'name': '뿌뿌로',
        'level': 'Lv.10',
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
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: medalColor, width: 4),
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
        Text(level, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
