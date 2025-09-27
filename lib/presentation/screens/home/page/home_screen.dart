import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/ai_chat_circle.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_background.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_card.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_progress.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/monji_jump.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color userColor = const Color(0xFF1A1A1A); // 기본 색상

  @override
  void initState() {
    super.initState();
    _loadUserColor();
  }

  Future<void> _loadUserColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('monji_color') ?? 0xFF1A1A1A;
    if (mounted) {
      setState(() {
        userColor = Color(colorValue);
      });
    }
  }

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
            const Text(
              '자취의 정석',
              style: TextStyle(
                fontFamily: 'GamjaFlower',
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
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

          final circleCenter = Offset(stackWidth * 0.73, stackHeight * 0.464);
          final circleRadius = stackWidth * 0.05;

          return Stack(
            children: [
              const HomeBackground(),
              Center(child: MonjiJump(bodyColor: userColor)),
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
                  children: const [
                    HomeProgress(),
                    SizedBox(height: 8),
                    HomeCard(),
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
