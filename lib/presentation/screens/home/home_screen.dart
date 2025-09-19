import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_background.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_card.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/monji_jump.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_progress.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자취의 정석')),
      body: Stack(
        children: [
          const HomeBackground(),
          //레벨// 위젯으로 빼거나 불러오가
          // HomeProgress(),
          // HomeCard(),
          // Align(
          //         alignment: Alignment.topCenter,
          //         child: Center(child: MonjiJump()),
          //       ),
                  Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              children: [
                // 레벨 ProgressBar
                HomeProgress(),

                const SizedBox(height: 20),

                // 미션
                HomeCard(),

                const SizedBox(height: 58),

                // 캐릭터
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topCenter,
                  child: Center(child: MonjiJump()),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:BottomNav(mode: BottomNavMode.tab)
    );
  }
}
