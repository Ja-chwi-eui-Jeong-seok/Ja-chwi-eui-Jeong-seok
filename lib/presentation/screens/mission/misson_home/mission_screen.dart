import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
// import 'package:ja_chwi/presentation/screens/mission/mission_Achievers_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/achiever_card.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/app_bottom_navigation_bar.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/go_to_completed_button.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/mission_card.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/profile_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int _currentIndex = 1;

  // 오늘의 미션 달성자 임시 데이터
  final List<Map<String, String>> _achievers = [
    {'name': '집인데 집가고 싶다님', 'time': '08:12 완료'},
    {'name': '아니 아님', 'time': '09:12 완료'},
    {'name': '뿌뿌로', 'time': '10:12 완료'},
    {'name': '네번째 달성자', 'time': '11:00 완료'},
    {'name': '다섯번째 달성자', 'time': '12:00 완료'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(actions: [RefreshIconButton(onPressed: () {})]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [const ProfileSection(), const GoToCompletedButton()],
              ),
              const SizedBox(height: 32),
              _buildTodayMissionSection(),
              const SizedBox(height: 32),
              _buildMissionAchieversSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        // 임시 네비게이터임
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // TODO: 각 탭에 대한 화면 전환 로직 추가
          });
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildTodayMissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('오늘의 미션'),
        const MissionCard(title: '삼시세끼 다 먹기', tags: ['건강']),
      ],
    );
  }

  Widget _buildMissionAchieversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '오늘의 미션 달성자',
          action: TextButton(
            onPressed: () => context.push('/mission-achievers'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              children: [
                Text('더보기', style: TextStyle(color: Colors.grey)),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xD3D3D3D3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _achievers.take(3).length; i++) ...[
                AchieverCard(
                  name: _achievers[i]['name']!,
                  time: _achievers[i]['time']!,
                  backgroundColor: Colors.white,
                ),
                if (i < _achievers.take(3).length - 1)
                  const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
