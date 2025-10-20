import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_model.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/mission_card.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/achiever_profile_tile.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/profile_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class MissionHomeScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const MissionHomeScreen({super.key, this.extra});

  @override
  ConsumerState<MissionHomeScreen> createState() => _MissionHomeScreenState();
}

class _MissionHomeScreenState extends ConsumerState<MissionHomeScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯이 초기화될 때마다 관련 데이터를 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userProfileProvider);
      ref.invalidate(todayMissionProvider);
      ref.invalidate(currentWeekAchieversProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekAchieversAsync = ref.watch(currentWeekAchieversProvider);

    final todayMissionAsync = ref.watch(todayMissionProvider);
    return Scaffold(
      appBar: CommonAppBar(
        actions: [
          RefreshIconButton(
            onPressed: () {
              ref.invalidate(userProfileProvider); // dongName을 다시 가져오기 위해 추가
              ref.invalidate(todayMissionProvider);
              ref.invalidate(currentWeekAchieversProvider);
            },
          ),
        ],
        titleSpacing: 20.0,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const ProfileSection(),
              const SizedBox(height: 32),
              _buildTodayMissionSection(context, todayMissionAsync),
              const SizedBox(height: 40),
              _buildMissionAchieversSection(
                context,
                ref,
                currentWeekAchieversAsync,
              ),
              const SizedBox(height: 140), // 하단 여백 추가
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        mode: BottomNavMode.tab,
        userData: widget.extra ?? {},
      ),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildTodayMissionSection(
    BuildContext context,
    AsyncValue<Mission> todayMissionAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '오늘의 미션'),
        todayMissionAsync.when(
          data: (mission) => MissionCard(
            title: mission.missiontitle,
            tags: mission.tags,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              '미션을 불러오는 데 실패했습니다: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMissionAchieversSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<MissionAchiever>> currentWeekAchieversAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          '주간 미션 랭킹',
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
        const SizedBox(height: 16),
        currentWeekAchieversAsync.when(
          data: (achievers) {
            if (achievers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/profile/tung.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '아직 아무도 달성 못했어요...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이웃보다 먼저 순위에 도달해보세요!',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: List.generate(achievers.take(3).length, (i) {
                final achiever = achievers[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AchieverProfileTile(
                    achiever: achiever,
                    leading: SizedBox(
                      width: 32,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('달성자 정보를 불러오지 못했습니다: $error')),
        ),
      ],
    );
  }
}
