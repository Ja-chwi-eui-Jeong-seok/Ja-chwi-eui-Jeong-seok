import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // 다시보지 않기용
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide1.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide2.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide3.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide4.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide5.dart';
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

  late final List<Widget Function(VoidCallback)> steps;

  @override
  void initState() {
    super.initState();
    final args = widget.extra;
    uid = args?['uid'];
    nickname = args?['nickname'];
    imageFullUrl = args?['imageFullUrl'];
    thumbUrl = args?['thumbUrl'];
    color = args?['color'];
    // steps = [
    //   (next) => Guide1(onNext: next),
    //   (next) => Guide2(onNext: next),
    //   (next) => Guide3(onNext: next),
    //   (next) => Guide4(onNext: next),
    //   (next) => Guide5(onNext: next),
    // ];
    print('GuideScreen initState');
    print('uid: $uid, nickname: $nickname');
    print('imageFullUrl: $imageFullUrl, color: $color');
    steps = [
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
      ),
      (next) => Guide4(
        uid: uid,
        nickname: nickname,
        imageFullUrl: imageFullUrl,
        thumbUrl: thumbUrl,
        color: color,
        onNext: next,
      ),
      (next) => Guide5(
        uid: uid,
        nickname: nickname,
        imageFullUrl: imageFullUrl,
        thumbUrl: thumbUrl,
        color: color,
        onNext: next,
      ),
    ];
  }

  void _nextStep() {
    setState(() {
      if (current < steps.length - 1) {
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

  // Future<void> _closeGuide({bool dontShowAgain = false}) async {
  //   if (dontShowAgain) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setBool('dontShowGuide', true);
  //   }
  //   if (!mounted) return; // 🔒 context 안전성 확보
  //   GoRouter.of(context).go('/home');
  // }

  // 홈 캐릭터 생상 불러오기 완료
  @override
  Widget build(BuildContext context) {
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

        // 현재 단계 가이드
        steps[current](_nextStep),
      ],
    );
  }
}
