import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/ai_chat_circle.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/circle_config.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_background.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_card.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/home_progress.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/monji_jump.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  final GlobalKey? missionKey;
  final GlobalKey? communityKey;

  const HomeScreen({
    super.key,
    this.extra,
    this.missionKey,
    this.communityKey,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    userData = widget.extra;
    print('HomeScreen 데이터: $userData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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

          final circleCenter = AiChatCircleConfig.getCenter(
            Size(stackWidth, stackHeight),
          );
          final circleRadius = AiChatCircleConfig.getRadius(
            Size(stackWidth, stackHeight),
          );

          return Stack(
            children: [
              const HomeBackground(),
              Center(
                child: MonjiJump(
                  bodyColor: Color(
                    int.parse('0xFF${userData?['color'] ?? '1A1A1A'}'),
                  ),
                ),
              ),
              AiChatCircle(
                center: circleCenter,
                radius: circleRadius,
                onTap: () {
                  GoRouter.of(context).push('/ai-chat', extra: userData);
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
      // userData 가 null일 경우 null 반환 → 에러 방지
      bottomNavigationBar: userData == null
          ? null
          : BottomNav(
              mode: BottomNavMode.tab,
              userData: userData!,
              missionKey: widget.missionKey,
              communityKey: widget.communityKey,
            ),
    );
  }
}
