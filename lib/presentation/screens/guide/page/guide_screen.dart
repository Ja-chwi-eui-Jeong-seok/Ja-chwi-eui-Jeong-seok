import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  // 🔹 GlobalKey 생성
  final GlobalKey missionKey = GlobalKey();
  final GlobalKey communityKey = GlobalKey();

  Offset missionIconPos = Offset.zero;
  Offset communityIconPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    final args = widget.extra;
    uid = args?['uid'];
    nickname = args?['nickname'];
    imageFullUrl = args?['imageFullUrl'];
    thumbUrl = args?['thumbUrl'];
    color = args?['color'];

    // 🔹 프레임 렌더링 이후에 위치 계산
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        missionIconPos = _getWidgetCenter(missionKey);
        communityIconPos = _getWidgetCenter(communityKey);
      });
    });
  }

  Offset _getWidgetCenter(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    }
    return Offset.zero;
  }

  void _nextStep() {
    if (current < 4) {
      setState(() {
        current++;
      });
    } else {
      // 빌드 중 호출되지 않도록 예약
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(
          '/home',
          extra: {
            'uid': uid,
            'nickname': nickname,
            'imageFullUrl': imageFullUrl,
            'thumbUrl': thumbUrl,
            'color': color,
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final circleCenter = GuideCircleConfig.getCenter(size);
        final circleRadius = GuideCircleConfig.getRadius(size);

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
            circleCenter: missionIconPos,
            circleRadius: 30,
          ),
          (next) => Guide5(
            uid: uid,
            nickname: nickname,
            imageFullUrl: imageFullUrl,
            thumbUrl: thumbUrl,
            color: color,
            onNext: next,
            circleCenter: communityIconPos,
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
              // 🔹 키 전달
              missionKey: missionKey,
              communityKey: communityKey,
            ),
            if (missionIconPos != Offset.zero &&
                communityIconPos != Offset.zero)
              steps[current](_nextStep),
          ],
        );
      },
    );
  }
}
