import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/ai_chat_circle.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_background.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_card.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/monji_jump.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // _checkguide();
  }

  // Future<void> _checkguide() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final showguide = prefs.getBool('showguide') ?? true;

  //   // if (showguide) {
  //   //   await prefs.setBool('showguide', false); // 다음부터는 안 보이게
  //   if (mounted) {
  //     GoRouter.of(context).push('/guide'); // 가이드 화면으로 이동
  //   }
  //   // }
  // }

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
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                print('알림 창');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const HomeBackground(),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                MonjiJump(),
                AiChatCircle(
                  circleSize: 40,
                  offsetX: -10,
                  offsetY: 80,
                  icon: CupertinoIcons.chat_bubble_text,
                  onTap: () {
                    print('Ai챗');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const HomeProgress(),
                const SizedBox(height: 8),
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
