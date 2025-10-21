// admin.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';



class AdminScreen extends ConsumerWidget {
  //const AdminScreen({super.key, required String myUid});
    final Map<String, dynamic> extra;  // 멤버 변수 선언

  const AdminScreen({
    super.key,
    required this.extra,   // 생성자에서 저장
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("관리자 설정", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/settings', extra: extra),
        ),
      ),
      body: ListView(
        children: [
        // 신고 내역
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text("신고 내역 관리", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onTap: () {
              context.go('/all-reports', extra: extra);
            },
          ),
          // 차단 내역
          ListTile(
            leading: const Icon(Icons.do_not_disturb_on_outlined),
            title: const Text("차단 내역 관리", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () {
                context.go('/all-block', extra: extra);
              },
          ),
          Divider(
            color: Colors.grey,   // 선 색상
            thickness: 2,          // 선 두께
            indent: 40,            // 왼쪽 여백
            endIndent: 20,         // 오른쪽 여백
          ),
           ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("미션 등록", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onTap: () {
              // 관리자 화면 이동
              context.go('/mission-list', extra: extra);
            },
          ),
          // 관리자 메뉴 (권한 체크)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("카테고리 코드 등록", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onTap: () {
                // 관리자 화면 이동
                context.go('/category', extra: extra);
              },
            ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("도움말 등록", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onTap: () {
              // 관리자 화면 이동
              context.go('/help-admin', extra: extra);
            },
          ),
          Divider(
            color: Colors.grey,   // 선 색상
            thickness: 2,          // 선 두께
            indent: 40,            // 왼쪽 여백
            endIndent: 20,         // 오른쪽 여백
          ),
        ],
      ),
    );
  }
}
