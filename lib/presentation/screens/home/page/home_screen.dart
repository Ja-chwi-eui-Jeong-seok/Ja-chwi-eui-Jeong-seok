import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/ai_chat_circle.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_background.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_card.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/monji_jump.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_progress.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  //해야할 것:
  // 4 ai챗 버튼,
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '자취의 정석',
                style: TextStyle(
                  fontFamily: 'GamjaFlower',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),

            // 종 아이콘
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                print('알림 창');
                // 알림 버튼
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const HomeBackground(), // 배경
          // CharacterCircle
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                MonjiJump(), // 캐릭터
                // ai챗
                AiChatCircle(
                  circleSize: 40,
                  offsetX: -10,
                  offsetY: 80,
                  icon: CupertinoIcons.chat_bubble_text,
                  onTap: () {
                    // 나중에 ai 채팅으로 이동
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 레벨
                const HomeProgress(),

                const SizedBox(height: 8),
                // 미션
                const HomeCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(mode: BottomNavMode.tab),
    );
  }
}
