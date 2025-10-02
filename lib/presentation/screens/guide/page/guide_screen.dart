import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide1.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide2.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide3.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide4.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide5.dart';
import 'package:ja_chwi/presentation/screens/home/home_widget/circle_config.dart';
import 'package:ja_chwi/presentation/screens/home/page/home_screen.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key, this.extra});

  final Map<String, dynamic>? extra;

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int current = 0;
  late final String uid;
  late final String nickname;
  late final String? imageFullUrl;
  late final String? thumbUrl;
  late final String? color;
  late final BottomNav bottomNav;

  @override
  void initState() {
    super.initState();
    final args = widget.extra;
    uid = args?['uid'];
    nickname = args?['nickname'];
    imageFullUrl = args?['imageFullUrl'];
    thumbUrl = args?['thumbUrl'];
    color = args?['color'];
    bottomNav = BottomNav();

    print('GuideScreen initState');
    print('uid: $uid, nickname: $nickname');
    print('imageFullUrl: $imageFullUrl, color: $color');
  }

  // Mission 아이콘 위치
  Offset getMissionIconPosition() {
    final renderBox =
        bottomNav.missionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    }
    return Offset.zero;
  }

  // Community 아이콘 위치
  Offset getCommunityIconPosition() {
    final renderBox =
        bottomNav.communityKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    }
    return Offset.zero;
  }

  void _nextStep() {
    setState(() {
      if (current < 4) {
        current++;
      } else {
        GoRouter.of(context).go(
          '/home',
          extra: {
            'uid': uid,
            'nickname': nickname,
            'imageFullUrl': imageFullUrl,
            'thumbUrl': thumbUrl,
            'color': color,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackWidth = constraints.maxWidth;
        final stackHeight = constraints.maxHeight;
        final circleCenter = GuideCircleConfig.getCenter(
          Size(stackWidth, stackHeight),
        );
        final circleRadius = GuideCircleConfig.getRadius(
          Size(stackWidth, stackHeight),
        );

        // 단계별 위젯
        final steps = [
          (next) => Guide1(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
          ),
          (next) => Guide2(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
          ),
          (next) => Guide3(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
            circleCenter: circleCenter,
            circleRadius: circleRadius,
          ),
          (next) => Guide4(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
            circleCenter: getMissionIconPosition(), // ← BottomNav 실제 위치
            circleRadius: 30,
          ),
          (next) => Guide5(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
            circleCenter: getCommunityIconPosition(), // ← BottomNav 실제 위치
            circleRadius: 30,
          ),
        ];

        return Stack(
          children: [
            HomeScreen(
              extra: {
                'uid': uid,
                'nickname': nickname,
                'imageFullUrl': imageFullUrl,
                'thumbUrl': thumbUrl,
                'color': color,
              },
            ),
            steps[current](_nextStep),
          ],
        );
      },
    );
  }
}
