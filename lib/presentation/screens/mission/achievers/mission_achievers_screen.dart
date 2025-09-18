import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/achievers_list.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/category_tabs.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/widgets/mission_info_box.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionAchieversScreen extends StatefulWidget {
  const MissionAchieversScreen({super.key});

  @override
  State<MissionAchieversScreen> createState() => MissionAchieversScreenState();
}

class MissionAchieversScreenState extends State<MissionAchieversScreen> {
  // TODO: 실제 미션 데이터는 상태관리(Provider, BLoC 등)를 통해 가져와야 합니다.
  final String _missionTitle = '삼시세끼 다 먹기';
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
            MissionInfoBox(missionTitle: _missionTitle),
            const SizedBox(height: 24),
            _buildSectionHeader('사용자들'),
            Expanded(child: AchieversList(achievers: _allAchievers)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
