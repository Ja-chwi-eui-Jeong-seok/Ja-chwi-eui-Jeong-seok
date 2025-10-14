import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/core/config/router/router.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _navigationDone = false; // ✅ 추가

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        await _checkUserAndNavigate();
      }
    });
  }

  Future<void> _checkUserAndNavigate() async {
    if (_navigationDone) return; // ✅ 중복 실행 방지
    _navigationDone = true;

    final firestore = FirebaseFirestore.instance;

    // 🔹 Firebase 캐시 초기화
    await firestore.clearPersistence().catchError((e) {
      print('Firestore cache clear error: $e');
    });

    // 🔹 Auth 상태 강제 갱신
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.go('/login');
      });
      return;
    }

    try {
      final userProfileDoc = await firestore
          .collection('user_profile')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (!userProfileDoc.exists) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/login');
        });
        return;
      }

      final usersDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      final usersData = usersDoc.data();
      final privacyConsent = (usersData?['privacy_consent'] ?? false) == true;

      if (!privacyConsent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/privacy-policy');
        });
        return;
      }

      final profilesDoc = await firestore
          .collection('profiles')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      final profilesData = profilesDoc.data();
      final nickname = profilesData?['nickname'] ?? '';

      if (nickname.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/profile-flow');
        });
        return;
      }

      final extraData = {
        'uid': user.uid,
        'nickname': nickname,
        'thumbUrl': profilesData?['thumbUrl'] ?? '',
        'mission_count': profilesData?['mission_count'] ?? 0,
        'imageFullUrl': profilesData?['imageFullUrl'] ?? '',
        'color': profilesData?['color'] ?? '',
        'managerType': userProfileDoc.data()?['manager_type'] ?? false,
        'privacyConsent': privacyConsent,
      };

      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.go('/home', extra: extraData);
      });
    } catch (e) {
      print('🔥 Splash navigation error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.go('/login');
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '자취의 정석',
              style: TextStyle(
                fontSize: 52,
                fontFamily: 'GamjaFlower',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Builder(
                builder: (_) {
                  try {
                    return Lottie.asset(
                      'assets/config/json/intro_monji.json',
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller
                          ..duration = composition.duration
                          ..forward();
                      },
                    );
                  } catch (e) {
                    print('Lottie load error: $e');
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
