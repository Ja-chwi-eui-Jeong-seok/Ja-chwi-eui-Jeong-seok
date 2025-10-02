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

  @override
  void initState() {
    super.initState();
    final args = widget.extra;
    uid = args?['uid'];
    nickname = args?['nickname'];
    imageFullUrl = args?['imageFullUrl'];
    thumbUrl = args?['thumbUrl'];
    color = args?['color'];

    print('GuideScreen initState');
    print('uid: $uid, nickname: $nickname');
    print('imageFullUrl: $imageFullUrl, color: $color');
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
            circleCenter: Guide4CircleConfig.getCenter(
              Size(stackWidth, stackHeight),
            ),
            circleRadius: Guide4CircleConfig.getRadius(
              Size(stackWidth, stackHeight),
            ),
          ),
          (next) => Guide5(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
            circleCenter: Guide5CircleConfig.getCenter(
              Size(stackWidth, stackHeight),
            ),
            circleRadius: Guide5CircleConfig.getRadius(
              Size(stackWidth, stackHeight),
            ),
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
