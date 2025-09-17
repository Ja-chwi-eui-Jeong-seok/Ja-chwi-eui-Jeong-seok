import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class RouteTitles {
  static const Map<String, String> map = {
    '/login': '로그인',
    '/character-create': '캐릭터 생성',
    '/home': '메인',
    '/mission': '미션',
    '/mission-create': '미션 작성',
    '/mission-saved-list': '미션 저장목록',
    '/mission-edit': '미션 수정',
    '/mission-achievers': '미션 달성자목록',
    '/community': '커뮤니티',
    '/community-detail': '커뮤니티 상세',
    '/community-create': '커뮤니티 작성',
    '/profile': '프로필',   
    '/admin': '관리자',   
    '/report': '신고 내역',    
    '/report-detail': '신고내역 상세',
    
  };

  static String of(BuildContext context) {
    final loc = GoRouterState.of(
      context,
    ).matchedLocation; // ex) '/community-detail'
    String? bestKey;
    for (final k in map.keys) {
      if (loc.startsWith(k)) {
        if (bestKey == null || k.length > bestKey.length) bestKey = k;
      }
    }
    return bestKey != null ? map[bestKey] ?? '' : '';
  }
}
