import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/go_to_completed_button.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/mission_card.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/profile_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/achiever_card.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class MissionHomeScreen extends ConsumerWidget {
  const MissionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievers = ref.watch(achieversProvider);
    return Scaffold(
      appBar: CommonAppBar(actions: [RefreshIconButton(onPressed: () {})]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const ProfileSection(),
              const SizedBox(height: 32),
              _buildTodayMissionSection(context),
              const SizedBox(height: 32),
              _buildMissionAchieversSection(context, achievers),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(mode: BottomNavMode.tab),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildTodayMissionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '오늘의 미션'),
        const MissionCard(title: '삼시세끼 다 먹기', tags: ['건강']),
        const SizedBox(height: 12),
        const SizedBox(width: double.infinity, child: GoToCompletedButton()),
      ],
    );
  }

  Widget _buildMissionAchieversSection(
    BuildContext context,
    List<MissionAchiever> mockAllAchievers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
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
              for (int i = 0; i < mockAllAchievers.take(3).length; i++) ...[
                AchieverCard(
                  level: mockAllAchievers[i].level,
                  name: mockAllAchievers[i].name,
                  time: mockAllAchievers[i].time,
                  backgroundColor: Colors.white,
                ),
                if (i < mockAllAchievers.take(3).length - 1)
                  const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
