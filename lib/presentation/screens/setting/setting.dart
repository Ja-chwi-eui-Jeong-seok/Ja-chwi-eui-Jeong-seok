// settings.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/domain/usecases/auth_usecase.dart';
import 'package:ja_chwi/data/repositories/auth_repository_impl.dart';
import 'package:ja_chwi/data/datasources/auth_datasource.dart';
import 'dart:io';

// 다크모드 상태 관리
final darkModeProvider = StateProvider<bool>((ref) => false);

// 사용자 역할 예제 (true = 관리자, false = 일반 사용자)
final isAdminProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerWidget {
  final Map<String, dynamic> extra; // 멤버 변수 선언

  const SettingsPage({
    super.key,
    required this.extra, // 생성자에서 저장
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
        title: const Text("설정"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () =>
              context.go('/profile-detail', extra: extra), // 프로필 화면으로 이동
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
            color: Colors.grey, // 선 색상
            thickness: 2, // 선 두께
            indent: 40, // 왼쪽 여백
            endIndent: 20, // 오른쪽 여백
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

          // 계정 비활성화
          // ListTile(
          //   leading: const Icon(Icons.pause_circle, color: Colors.orange),
          //   title: const Text(
          //     "계정 비활성화",
          //     style: TextStyle(color: Colors.orange),
          //   ),
          //   onTap: () {
          //     _showDeactivateAccountDialog(context, uid);
          //   },
          // ),

          // 계정 완전 삭제
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("계정 완전 삭제", style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteAccountDialog(context, uid);
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

  void _showDeactivateAccountDialog(BuildContext context, String? uid) {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("계정 비활성화"),
          content: const Text(
            "계정을 비활성화하면 로그인이 제한됩니다.\n"
            "60일 후 계정과 모든 데이터가 자동으로 삭제됩니다.\n"
            "이 기간 동안은 계정을 복구할 수 있습니다.\n\n"
            "계정을 비활성화하시겠습니까?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => _deactivateAccount(context, uid),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text("비활성화"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String? uid) {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("계정 삭제"),
          content: const Text(
            "계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.\n"
            "이 작업은 되돌릴 수 없습니다.\n\n"
            "정말로 계정을 삭제하시겠습니까?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => _confirmDeleteAccount(context, uid),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("최종 확인"),
          content: const Text(
            "계정 삭제를 진행하시겠습니까?\n"
            "모든 데이터가 영구적으로 삭제됩니다.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => _deleteAccount(context, uid),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("삭제 진행"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deactivateAccount(BuildContext context, String uid) async {
    // 다이얼로그 닫기
    Navigator.pop(context);

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 계정 비활성화 실행 (soft delete)
      final authDataSource = AuthRemoteDataSourceImpl();
      final authRepository = AuthRepositoryImpl(
        remoteDataSource: authDataSource,
      );
      final deleteUseCase = DeleteUserUseCase(authRepository);

      await deleteUseCase.execute(uid, reason: '사용자 요청');

      // 로딩 다이얼로그 닫기 (mounted 체크)
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 성공 메시지 (mounted 체크)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계정이 비활성화되었습니다.')),
        );
      }

      // 로그인 화면으로 이동 (mounted 체크)
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기 (mounted 체크)
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 에러 메시지 (mounted 체크)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정 비활성화 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, String uid) async {
    if (kDebugMode) {
      print('🔴 계정 삭제 시작: $uid');
    }

    // 다이얼로그 닫기
    Navigator.pop(context);

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 계정 삭제 실행
      final authDataSource = AuthRemoteDataSourceImpl();
      final authRepository = AuthRepositoryImpl(
        remoteDataSource: authDataSource,
      );
      final deleteUseCase = DeleteUserAccountUseCase(authRepository);

      // 계정 삭제 실행
      await deleteUseCase.execute(uid, reason: '사용자 요청');

      // 계정 삭제 완료 후 로딩 다이얼로그 닫기
      try {
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {}

      // 성공 메시지 표시 (현재 화면에서)
      try {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('계정이 성공적으로 삭제되었습니다.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {}

      // 3초 후 로그인 화면으로 이동 (사용자가 메시지를 읽을 시간 제공)
      Future.delayed(const Duration(seconds: 3), () {
        try {
          if (context.mounted) {
            context.go('/login');
          } else {
            // 위젯이 비활성화된 경우 앱 재시작
            try {
              SystemNavigator.pop();
              exit(0);
            } catch (e) {}
          }
        } catch (e) {
          // 이동 실패 시 앱 재시작
          try {
            SystemNavigator.pop();
            exit(0);
          } catch (e2) {}
        }
      });
    } catch (e) {
      // 로딩 다이얼로그 닫기 (mounted 체크)
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 에러 메시지 (mounted 체크)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정 삭제 실패: $e')),
        );
      }
    }
  }
}
