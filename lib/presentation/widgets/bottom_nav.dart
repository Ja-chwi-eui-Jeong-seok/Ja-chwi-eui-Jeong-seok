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

  const BottomNav({
    super.key,
    this.mode = BottomNavMode.tab,
    this.confirmRoute,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case BottomNavMode.tab:
        return _buildTabNav(context);
      case BottomNavMode.confirm:
        return _buildConfirmNav(context);
    }
  }

  Widget _buildTabNav(BuildContext context) {
    int currentIndex = _getCurrentIndex(context);

    final routes = [
      '/home',
      '/mission',
      '/community',
      '/profile-detail',
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
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
            onTap: (index) => context.go(routes[index]),
            selectedItemColor: Colors.red,      // 선택된 아이콘 + 텍스트 색상
            unselectedItemColor: Colors.grey,   // 선택되지 않은 아이콘 색상
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 30.0), label: "홈"),
              BottomNavigationBarItem(icon: Icon(Icons.article_outlined, size: 30.0), label: "미션"),
              BottomNavigationBarItem(icon: Icon(Icons.groups_outlined, size: 30.0), label: "커뮤니티"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 30.0), label: "내 정보"),
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
