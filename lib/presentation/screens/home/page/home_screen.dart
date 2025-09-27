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
  //   if (mounted) {
  //     GoRouter.of(context).push('/guide'); // 가이드 화면으로 이동
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 한 번만 읽고 재사용
    final screenSize = MediaQuery.of(context).size;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final stackWidth = constraints.maxWidth;
          final stackHeight = constraints.maxHeight;

          final circleCenter = Offset(
            stackWidth * 0.73,
            stackHeight * 0.464, // Stack 안에서 계산
          );
          final circleRadius = stackWidth * 0.05;

          return Stack(
            children: [
              const HomeBackground(),
              Center(child: MonjiJump()),
              AiChatCircle(
                center: circleCenter,
                radius: circleRadius,
                onTap: () {
                  GoRouter.of(context).go('/ai-chat');
                },
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
          );
        },
      ),
      bottomNavigationBar: BottomNav(mode: BottomNavMode.tab),
    );
  }
}
