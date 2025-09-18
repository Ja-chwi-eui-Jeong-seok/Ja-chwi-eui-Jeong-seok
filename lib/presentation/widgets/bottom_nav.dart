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

  const BottomNav({
    super.key,
    this.mode = BottomNavMode.tab,
    this.confirmRoute,
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
      '/profile',
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => context.go(routes[index]),
      backgroundColor: Colors.transparent, // 배경 투명
      elevation: 0, // 그림자 제거
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "미션"),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: "커뮤니티"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "내 정보"),
      ],
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final routes = ['/home', '/mission', '/community', '/profile'];
    final index = routes.indexWhere((route) => location.startsWith(route));
    return index != -1 ? index : 0;
  }

  Widget _buildConfirmNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          if (confirmRoute != null) {
            context.go(confirmRoute!);
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text('확인'),
      ),
    );
  }
}
