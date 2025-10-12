// settings.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 다크모드 상태 관리
final darkModeProvider = StateProvider<bool>((ref) => false);

// 사용자 역할 예제 (true = 관리자, false = 일반 사용자)
final isAdminProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  final Map<String, dynamic> extra;  // 멤버 변수 선언

  const SettingsPage({
    super.key,
    required this.extra,   // 생성자에서 저장
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = extra['uid'] as String?; // extra에서 uid 추출
    final managerType = extra['managerType'] as bool?; // extra에서 권한 읽기
    print('SettingsPage extra: $extra'); // ✅ 데이터 확인
    final isAdmin = managerType == true; // admin이면 true
    

    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("설정") ,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/profile-detail', extra: extra), // 프로필 화면으로 이동
        ),
      ),
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
              context.go('/my-report', extra: extra);
            },
          ),
          // 차단 내역
          ListTile(
            leading: const Icon(Icons.do_not_disturb_on_outlined),
            title: const Text("차단 내역"),
             onTap: () {
                context.go('/my-block', extra: extra);
              },
          ),
          // 도움말
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("도움말"),
            onTap: () {
              context.go('/help', extra: extra);
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
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // 1️⃣ Firebase 로그아웃
                        await FirebaseAuth.instance.signOut();

                        // 2️⃣ 다이얼로그 닫기
                        Navigator.pop(context);

                        // // 3️⃣ 홈 또는 로그인 화면으로 이동 (뒤로가기 모두 제거)
                        // Navigator.popUntil(context, (route) => route.isFirst);

                        // 만약 GoRouter 사용 시:
                        context.go('/login');
                      },
                      child: const Text("로그아웃"),
                    ),
                  ],
                ),
              );
            },
          ),
         // 관리자 메뉴 (권한 체크)
          if (isAdmin)  
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("관리자"),
              onTap: () {
                // 관리자 화면 이동
                context.go('/admin', extra: extra);
              },
            ),  
            //  ListTile(
            //   leading: const Icon(Icons.admin_panel_settings),
            //   title: const Text("차단등록"),
            //   onTap: () {
            //     // 관리자 화면 이동
            //     context.go('/block-user', extra: extra);
            //   },
            // ),             
            // ListTile(
            //   leading: const Icon(Icons.admin_panel_settings),
            //   title: const Text("신고등록"),
            //   onTap: () {
            //     // 관리자 화면 이동
            //     context.go('/report-user', extra: extra);
            //   },
            // ),
        ],
      ),
    );
  }
}
