import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/widgets/achiever_card.dart';

class AchieversList extends StatelessWidget {
  final List<MissionAchiever> achievers;

  const AchieversList({super.key, required this.achievers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: achievers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final achiever = achievers[index];
        return AchieverCard(
          rank: index + 1, // 등수는 1부터 시작하므로 index + 1
          name: achiever.name,
          level: achiever.level,
        );
      },
    );
  }
}
