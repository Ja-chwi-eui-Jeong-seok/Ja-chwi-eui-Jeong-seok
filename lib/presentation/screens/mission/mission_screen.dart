import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_Achievers_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/achiever_card.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/app_bottom_navigation_bar.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/go_to_completed_button.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/mission_card.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/profile_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int _currentIndex = 1; // 현재 선택된 탭 인덱스 (1: 미션)

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
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // 뒤로가기 버튼 자동 생성 방지
      title: const Text(
        '자취의 정석',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        RefreshIconButton(
          onPressed: () {
            // TODO: 새로고침 로직 추가
          },
        ),
      ],
    );
  }

  // 섹션 제목을 만드는 헬퍼 메소드
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
        const MissionCard(
          // 미션 카드 위젯 사용 (isCompleted = false)
          title: '삼시세끼 다 먹기',
          tags: ['건강'],
        ),
      ],
    );
  }

  Widget _buildMissionAchieversSection() {
    const missionTitle = '삼시세끼 다 먹기';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '오늘의 미션 달성자',
          action: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MissionAchieversScreen(missionTitle: missionTitle),
                ),
              );
            },
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
