import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// // 1. 일반 페이지 → 탭 표시
// BottomNav(mode: BottomNavMode.tab);

// // 2. 확인 버튼만 표시 → 다음 페이지로 이동
// BottomNav(
//   mode: BottomNavMode.confirm,
//   confirmRoute: '/mission-create',
// );

enum BottomNavMode {
  tab, // 홈/미션/커뮤니티/내 정보
  confirm, // 확인 버튼
}

class BottomNav extends StatelessWidget {
  final BottomNavMode mode;
  final String? confirmRoute; // confirm 모드에서 이동할 경로
  final VoidCallback? onConfirm; // ✅ 추가
  final Map<String, dynamic>? userData; // 추가
  final GlobalKey? missionKey;
  final GlobalKey? communityKey;

  const BottomNav({
    super.key,
    this.mode = BottomNavMode.tab,
    this.confirmRoute,
    this.onConfirm,
    this.userData,
    this.missionKey,
    this.communityKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) {}, // 스와이프 제스처 무시
      onHorizontalDragUpdate: (_) {}, // 스와이프 제스처 무시
      child: switch (mode) {
        BottomNavMode.tab => _buildTabNav(context),
        BottomNavMode.confirm => _buildConfirmNav(context),
      },
    );
  }

  Widget _buildTabNav(BuildContext context) {
    int currentIndex = _getCurrentIndex(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.grey, // 테두리 색
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) {
              final routes = [
                '/home',
                '/mission',
                '/community',
                '/profile-detail',
              ];
              context.go(
                routes[index],
                extra: userData, // null 방지
              );
              print('BottomNav onTap: index=$index, userData=$userData');
            },
            // selectedItemColor: Colors.red,
            // unselectedItemColor: Colors.grey,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/icons/home.png',
                  width: 30,
                  height: 30,
                ),
                activeIcon: Image.asset(
                  'assets/images/icons/s_home.png',
                  width: 30,
                  height: 30,
                ),
                label: "홈",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/icons/mission.png',
                  width: 30,
                  height: 30,
                ),
                activeIcon: Image.asset(
                  'assets/images/icons/s_mission.png',
                  width: 30,
                  height: 30,
                ),
                label: "미션",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/icons/commu.png',
                  width: 30,
                  height: 30,
                ),
                activeIcon: Image.asset(
                  'assets/images/icons/s_commu.png',
                  width: 30,
                  height: 30,
                ),
                label: "커뮤니티",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/icons/profile.png',
                  width: 30,
                  height: 30,
                ),
                activeIcon: Image.asset(
                  'assets/images/icons/s_profile.png',
                  width: 30,
                  height: 30,
                ),
                label: "내 정보",
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final routes = ['/home', '/mission', '/community', '/profile-detail'];
    final index = routes.indexWhere((route) => location.startsWith(route));
    return index != -1 ? index : 0;
  }

  Widget _buildConfirmNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton(
        onPressed: () {
          if (onConfirm != null) {
            onConfirm!(); // ✅ 프로필 저장 실행
          }
          if (confirmRoute != null) {
            context.go(confirmRoute!);
          }
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(70),
        ),
        child: const Text('확인'),
      ),
    );
  }
}
