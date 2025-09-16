import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/achiever_card.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';

class MissionAchieversScreen extends StatefulWidget {
  final String? missionTitle;

  const MissionAchieversScreen({super.key, this.missionTitle});

  @override
  State<MissionAchieversScreen> createState() => MissionAchieversScreenState();
}

class MissionAchieversScreenState extends State<MissionAchieversScreen> {
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
            _buildCategoryTabs(),
            const SizedBox(height: 24),
            _buildMissionInfoBox(),
            const SizedBox(height: 24),
            _buildSectionHeader('사용자들'),
            Expanded(child: _buildAchieversList()),
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

  Widget _buildCategoryTabs() {
    return Column(
      children: [
        Row(
          children: List.generate(_categories.length, (index) {
            bool isSelected = _selectedCategoryIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    _categories[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(
          height: 2,
          child: Row(
            children: List.generate(_categories.length, (index) {
              return Expanded(
                child: Container(
                  color: _selectedCategoryIndex == index
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xD3D3D3D3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: '오늘의 미션 : ',
              style: TextStyle(color: Colors.grey[700]),
            ),
            TextSpan(text: widget.missionTitle ?? '미션 정보 없음'),
          ],
        ),
      ),
    );
  }

  Widget _buildAchieversList() {
    return ListView.separated(
      itemCount: _allAchievers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final achiever = _allAchievers[index];
        return AchieverCard(name: achiever['name']!, time: achiever['time']!);
      },
    );
  }
}
