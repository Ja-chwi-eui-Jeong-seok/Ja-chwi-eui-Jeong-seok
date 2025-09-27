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
  final Map<String, dynamic>? extra;

  const HomeScreen({super.key, this.extra});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String? uid;
  late final String? nickname;
  late final String? imageFullUrl;
  late final String? thumbUrl;
  late final String? color;
  @override
  void initState() {
    super.initState();
    // _checkguide();
    final args = widget.extra;
    uid = args?['uid'];
    nickname = args?['nickname'];
    imageFullUrl = args?['imageFullUrl'];
    thumbUrl = args?['thumbUrl'];
    color = args?['color'];

    print('HomeScreen initState');
    print('uid: $uid, nickname: $nickname');
    print('imageFullUrl: $imageFullUrl, color: $color');
  }

  // Future<void> _loadUserColor() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final colorValue = prefs.getInt('monji_color') ?? 0xFF1A1A1A;
  //   if (mounted) {
  //     setState(() {
  //       userColor = Color(colorValue);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ← 뒤로가기 버튼 비활성화
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
