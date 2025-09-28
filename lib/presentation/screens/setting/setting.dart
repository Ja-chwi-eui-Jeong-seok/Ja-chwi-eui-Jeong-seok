// settings.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 다크모드 상태 관리
final darkModeProvider = StateProvider<bool>((ref) => false);

// 사용자 역할 예제 (true = 관리자, false = 일반 사용자)
final isAdminProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("설정")),
      body: ListView(
        children: [
          // 다크 모드
          SwitchListTile(
            title: const Text("다크 모드"),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(darkModeProvider.notifier).state = value;
            },
            secondary: const Icon(Icons.bedtime_outlined), // 왼쪽에 아이콘 추가
          ),

          // 신고 내역
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text("신고 내역"),
            onTap: () {
              // 신고 내역 화면 이동
            },
          ),
          // 차단 내역
          ListTile(
            leading: const Icon(Icons.do_not_disturb_on_outlined),
            title: const Text("차단 내역"),
             onTap: () {
                context.go('/my-block-users');
              },
          ),
          // 도움말
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("도움말"),
            onTap: () {
              // 도움말 화면 이동
            },
          ),
        Divider(
  color: Colors.grey,   // 선 색상
  thickness: 2,          // 선 두께
  indent: 40,            // 왼쪽 여백
  endIndent: 20,         // 오른쪽 여백
),
          // 로그아웃
          ListTile(
            leading: const Icon(Icons.cancel_outlined),
            title: const Text("로그아웃"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("로그아웃"),
                  content: const Text("정말 로그아웃 하시겠습니까?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("취소")),
                    TextButton(
                        onPressed: () {
                          // 로그아웃 후 홈으로 이동
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text("로그아웃")),
                  ],
                ),
              );
            },
          ),  // 관리자 메뉴 (권한 체크)
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("관리자"),
              onTap: () {
                // 관리자 화면 이동
              },
            ),
        ],
      ),
    );
  }
}
