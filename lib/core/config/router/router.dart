import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/auth/page/character_create_screen.dart';
import 'package:ja_chwi/presentation/screens/auth/page/login_screen.dart';
import 'package:ja_chwi/presentation/screens/auth/page/privacy_policy_page.dart';
import 'package:ja_chwi/presentation/screens/community/community_create_screen.dart';
import 'package:ja_chwi/presentation/screens/community/community_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/community/community_screen.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_screen.dart';
import 'package:ja_chwi/presentation/screens/guide/guide_widget/guide1.dart';
import 'package:ja_chwi/presentation/screens/home/page/home_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/achievers/mission_achievers_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/create/mission_create_screen.dart';
// import 'package:ja_chwi/presentation/screens/mission/mission_edit_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/saved_list/mission_saved_list_screen.dart';
import 'package:ja_chwi/presentation/screens/mission/misson_home/mission_home_screen.dart';
import 'package:ja_chwi/presentation/screens/profile/profile_screen.dart';
import 'package:ja_chwi/presentation/screens/admin/admin_screen.dart';
import 'package:ja_chwi/presentation/screens/profile/profile_detail.dart';
import 'package:ja_chwi/presentation/screens/report/report_screen.dart';
import 'package:ja_chwi/presentation/screens/report/report_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/splash/splash_screen.dart';
// AppBar 타이틀
// GoRouter는 현재 라우트 정보를 GoRouterState.of(context)로 제공한다.
// 그 안의 matchedLocation이나 uri를 읽으면 현재 경로(/mission-create 등)를 얻을 수 있다.
// RouteTitles.map은 경로 → 화면명(한글) 매핑 테이블이다.
// RouteTitles.of(context)는 현재 경로를 가져와서 가장 잘 맞는 key를 찾아, 해당 화면명을 반환한다.
// → 즉, 경로 /mission-create → '미션 작성'.
//final title = RouteTitles.of(context);
//라우트만 추가되면 RouteTitles.map에 새 경로를 매핑해주면 된다. 화면마다 수정할 필요 없음.

final GoRouter router = GoRouter(
  initialLocation: '/Guide',

  // initialLocation: '/profile',
  routes: [
    GoRoute(
      path: '/splash',
      name: '스플레시',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/Guide',
      name: '가이드',
      builder: (context, state) => const GuideScreen(),
    ),
    GoRoute(
      path: '/login',
      name: '로그인',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: '개인정보처리방침',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/character-create',
      name: '캐릭터 생성',
      builder: (context, state) => const CharacterCreateScreen(),
    ),
    GoRoute(
      path: '/home',
      name: '메인',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/mission',
      name: '미션',
      builder: (context, state) => const MissionHomeScreen(),
    ),
    GoRoute(
      path: '/mission-create',
      name: '미션 작성',
      builder: (context, state) => const MissionCreateScreen(),
    ),
    GoRoute(
      path: '/mission-saved-list',
      name: '미션 저장목록',
      builder: (context, state) => const MissionSavedListScreen(),
    ),
    GoRoute(
      path: '/mission-achievers',
      name: '미션 달성자목록',
      builder: (context, state) => const MissionAchieversScreen(),
    ),
    GoRoute(
      path: '/community',
      name: '커뮤니티',
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: '/community-detail',
      name: '커뮤니티 상세',
      builder: (context, state) => CommunityDetailScreen(),
    ),
    GoRoute(
      path: '/community-create',
      name: '커뮤니티 작성',
      builder: (context, state) => const CommunityCreateScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: '프로필',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile-detail',
      name: '프로필 상세',
      builder: (context, state) => const ProfileDetail(),
    ),
    GoRoute(
      path: '/admin',
      name: '관리자 메뉴',
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: '/report',
      name: '신고내역',
      builder: (context, state) => const ReportScreen(),
    ),
    GoRoute(
      path: '/report-detail',
      name: '신고내역 상세',
      builder: (context, state) => const ReportDetailScreen(),
    ),
  ],
);
