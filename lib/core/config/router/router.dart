import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/user_weekly_missions_screen.dart';
import 'package:ja_chwi/presentation/screens/add_mission/add_mission_list.dart';
import 'package:ja_chwi/presentation/screens/ai_chat/page/ai_chat.dart';
import 'package:ja_chwi/presentation/screens/auth/page/login_screen.dart';
import 'package:ja_chwi/presentation/screens/auth/page/privacy_policy_page.dart';
import 'package:ja_chwi/presentation/screens/block/block_user.dart';
import 'package:ja_chwi/presentation/screens/block/blocks.dart';
import 'package:ja_chwi/presentation/screens/block/my_block.dart';
import 'package:ja_chwi/presentation/screens/category/category.dart';
import 'package:ja_chwi/presentation/screens/community/community_create_screen.dart';
import 'package:ja_chwi/presentation/screens/community/community_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/community/community_screen.dart';
import 'package:ja_chwi/presentation/screens/guide/page/guide_screen.dart';
import 'package:ja_chwi/presentation/screens/help/help_admin.dart';
import 'package:ja_chwi/presentation/screens/help/help_page.dart';
import 'package:ja_chwi/presentation/screens/home/page/home_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/mission_achievers_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/core/model/mission_achiever.dart';
import 'package:ja_chwi/presentation/screens/mission/create/mission_create_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/mission_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/mission_saved_list_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/mission_home_screen.dart';
import 'package:ja_chwi/presentation/screens/profile/profile_flow.dart';
import 'package:ja_chwi/presentation/screens/profile/profile_screen.dart';
import 'package:ja_chwi/presentation/screens/admin/admin.dart';
import 'package:ja_chwi/presentation/screens/profile/profile_detail.dart';
import 'package:ja_chwi/presentation/screens/report/my_reports.dart';
import 'package:ja_chwi/presentation/screens/report/reports.dart';
import 'package:ja_chwi/presentation/screens/report/report_user.dart';
import 'package:ja_chwi/presentation/screens/report/report_screen.dart';
import 'package:ja_chwi/presentation/screens/report/report_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/setting/setting.dart';
import 'package:ja_chwi/presentation/screens/splash/splash_screen.dart';
import 'package:ja_chwi/presentation/widgets/location_auto.dart';
import 'package:ja_chwi/presentation/widgets/location_search.dart';
// AppBar 타이틀
// GoRouter는 현재 라우트 정보를 GoRouterState.of(context)로 제공한다.
// 그 안의 matchedLocation이나 uri를 읽으면 현재 경로(/mission-create 등)를 얻을 수 있다.
// RouteTitles.map은 경로 → 화면명(한글) 매핑 테이블이다.
// RouteTitles.of(context)는 현재 경로를 가져와서 가장 잘 맞는 key를 찾아, 해당 화면명을 반환한다.
// → 즉, 경로 /mission-create → '미션 작성'.
//final title = RouteTitles.of(context);
//라우트만 추가되면 RouteTitles.map에 새 경로를 매핑해주면 된다. 화면마다 수정할 필요 없음.

final GoRouter router = GoRouter(
  //initialLocation: '/my-block-users', //'/block-user',
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: '스플레시',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/guide',
      name: '가이드',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return GuideScreen(extra: args);
      },
    ),
    GoRoute(
      path: '/login',
      name: '로그인',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: '개인정보처리방침',
      builder: (context, state) => PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/home',
      name: '메인',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return NoTransitionPage(child: HomeScreen(extra: data));
      },
    ),
    GoRoute(
      path: '/ai-chat',
      name: 'ai채팅',
      builder: (context, state) => const AiChat(),
    ),
    GoRoute(
      path: '/mission',
      name: '미션',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return NoTransitionPage(child: MissionHomeScreen(extra: data));
      },
    ),
    GoRoute(
      path: '/mission-create',
      name: '미션 작성',
      builder: (context, state) => const MissionCreateScreen(),
    ),
    GoRoute(
      path: '/mission-detail',
      name: '미션 상세',
      builder: (context, state) {
        final missionData = state.extra as Map<String, dynamic>?;
        if (missionData == null) {
          return const Scaffold(
            body: Center(child: Text('미션 정보를 불러올 수 없습니다.')),
          );
        }
        return MissionDetailScreen(missionData: missionData);
      },
    ),
    GoRoute(
      path: '/mission-saved-list',
      name: '미션 저장목록',
      builder: (context, state) => const MissionSavedListScreen(),
    ),
    GoRoute(
      path: '/mission-achievers',
      name: '주간 미션 랭킹',
      builder: (context, state) => const MissionAchieversScreen(),
      routes: [
        GoRoute(
          path: 'user-missions',
          name: 'user-weekly-missions',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final achiever = extra?['achiever'] as MissionAchiever?;
            final weekDate = extra?['weekDate'] as DateTime?;

            if (achiever == null || weekDate == null) {
              return const Scaffold(body: Center(child: Text('잘못된 접근입니다.')));
            }
            return UserWeeklyMissionsScreen(
              achiever: achiever,
              weekDate: weekDate,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/community',
      name: '커뮤니티',
      pageBuilder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return NoTransitionPage(child: CommunityScreen(extra: args));
      },
      //builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: '/community-detail',
      name: '커뮤니티 상세',
      builder: (context, state) {
        final id = state.extra as String; // ← 리스트에서 넘긴 문서 id
        return CommunityDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/community-create',
      name: '커뮤니티 작성',
      builder: (context, state) => const CommunityCreateScreen(),
    ),
    GoRoute(
      path: '/community-edit',
      name: '커뮤니티 수정',
      builder: (context, state) {
        final id = state.extra as String;
        return CommunityCreateScreen(id: id);
      },
    ),
    GoRoute(
      path: '/profile-flow',

      redirect: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final uid = data?['uid'] as String?;
        return uid == null ? '/login' : null;
      },

      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final uid = data['uid'] as String; // redirect로 null 아님 보장
        return ProfileFlowPage(uid: uid, extra: data);
      },
    ),

    GoRoute(
      path: '/profile',
      name: '프로필',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ProfileScreen(extra: data);
      },
    ),
    GoRoute(
      path: '/location',
      name: '동명 불러오기',
      builder: (context, state) => const LocationSearchPage(),
    ),
    GoRoute(
      path: '/location_search',
      name: ' 불러오기',
      builder: (context, state) => const LocationAutocompleteWidget(),
    ),

    GoRoute(
      path: '/profile-detail',
      name: '프로필 상세',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return NoTransitionPage(child: ProfileDetail(extra: data));
      },
    ),
    GoRoute(
      path: '/admin',
      name: '관리자 메뉴',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return AdminScreen(extra: data);
      },
    ),
    GoRoute(
      path: '/my-report',
      name: '내가신고한내역',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return MyReportsPage(extra: data);
      },
    ),
    GoRoute(
      path: '/all-reports',
      name: '전체신고내역',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ReportsPage(extra: data);
      },
    ),
    GoRoute(
      path: '/report-user',
      name: '신고등록',
      builder: (context, state) => const ReportUserPage(
        myUid: 'DM6Fcg8NtYXEiRXlwC4VnI8R7N52', // 실제 UID 전달
        targetUid: 'MoDmwRSaBANwKlVLvyhEXgiD5Sn2',
      ),
    ),
    GoRoute(
      path: '/report',
      name: '신고하기',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ReportScreen(
          targetUserId: data['targetUserId'] as String,
          targetUserName: data['targetUserName'] as String?,
          targetContent: data['targetContent'] as String?,
          targetCreatedAt: data['targetCreatedAt'] as DateTime?,
        );
      },
    ),
    GoRoute(
      path: '/report-detail',
      name: '신고 세부사유',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ReportDetailScreen(
          targetUserId: data['targetUserId'] as String,
          targetUserName: data['targetUserName'] as String?,
          targetContent: data['targetContent'] as String?,
          targetCreatedAt: data['targetCreatedAt'] as DateTime?,
          selectedReason: data['selectedReason'] as String,
        );
      },
    ),
    //관리자가 uid 불러와 차단하는경우
    GoRoute(
      path: '/block-user',
      name: '차단등록',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return BlockUserPage(extra: data);
      },
    ),
    GoRoute(
      path: '/my-block',
      name: '내가차단한내역',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return MyBlocksPage(extra: data);
      },
    ),
    GoRoute(
      path: '/all-block',
      name: '전체차단내역',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return BlocksPage(extra: data);
      },
    ),
    GoRoute(
      path: '/settings',
      name: '설정',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return SettingsPage(extra: data);
      },
    ),
    // 도움말
    GoRoute(
      path: '/help',
      name: '도움말',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return HelpPage(extra: data);
      },
    ),
    GoRoute(
      path: '/help-admin',
      name: '도움말 등록',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return HelpAdminPage(extra: data);
      },
    ),
    GoRoute(
      path: '/mission-list',
      name: '미션 리스트',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return AddMissionList(extra: data);
      },
    ),
    GoRoute(
      path: '/category',
      name: '카테고리 리스트',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return CategoryPage(extra: data);
      },
    ),
  ],
);
