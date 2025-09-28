import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_model.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/mission_card.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/profile_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/refresh_icon_button.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class MissionHomeScreen extends ConsumerWidget {
    final Map<String, dynamic>? extra;
  const MissionHomeScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

     // extra 사용 가능
    print('MissionHomeScreen extra: $extra');
    
    final achievers = ref.watch(achieversProvider);

    final todayMissionAsync = ref.watch(todayMissionProvider);
    return Scaffold(
      appBar: CommonAppBar(
        actions: [
          RefreshIconButton(
            onPressed: () async {
              // Repository 자체를 새로고침하여 데이터 소스를 새로 만듭니다.
              ref.invalidate(missionRepositoryProvider);
              // 잠시 기다려 StateProvider가 업데이트되도록 합니다.
              await Future.delayed(const Duration(milliseconds: 50));
              // 의존하는 다른 Provider들을 새로고침합니다.
              ref.invalidate(todayMissionProvider);
              ref.invalidate(achieversProvider);
            },
          ),
        ],
        titleSpacing: 40.0,
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
              const SizedBox(height: 20),
              _buildMissionAchieversSection(context, achieversAsync),
              const SizedBox(height: 20), // 40
              /// 임시 로그아웃
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //요기까지
            ],
          ),
        ),
      ),
      bottomNavigationBar:  BottomNav( 
        mode: BottomNavMode.tab,
    userData: extra ?? {},),
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
    AsyncValue<List<MissionAchiever>> achieversAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
        achieversAsync.when(
          data: (achievers) {
            if (achievers.isEmpty) {
              return const Center(child: Text('오늘의 첫 달성자가 되어보세요!'));
            }
            return Column(
              children: List.generate(achievers.take(3).length, (i) {
                final achiever = achievers[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: ClipOval(
                          child: Image.asset(
                            achiever.imageFullUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achiever.level,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achiever.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        achiever.time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
