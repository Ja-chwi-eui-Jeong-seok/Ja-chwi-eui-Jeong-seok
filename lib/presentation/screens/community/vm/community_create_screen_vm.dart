import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityCreateVmProvider = Provider<CommunityCreateVm>(
  (ref) => CommunityCreateVm(),
);

class CommunityCreateVm {
  bool _submitting = false;
  bool get submitting => _submitting;

  /// 성공: null 반환, 실패: 에러 메시지 반환
  Future<String?> submit({
    required String title,
    required String content,
    required int? category,
    required int? subCategory,
  }) async {
    if (_submitting) return '처리 중입니다';
    final t = title.trim();
    final c = content.trim();
    if (t.isEmpty) return '제목을 입력하세요';
    if (c.isEmpty) return '내용을 입력하세요';
    if (category == null || subCategory == null) return '카테고리와 세부 카테고리를 선택하세요';

    _submitting = true;
    try {
      await FirebaseFirestore.instance.collection('communitylist').add({
        //커뮤니티코드 ?
        'categorycode': category,
        'categorydetailcode': subCategory,
        'communityname': t,
        'communitydetail': c,
        'createuser': '이영상',
        'categorycreatedate': FieldValue.serverTimestamp(),
        'categoryupdatedate': null,
        'categorydeletedate': null,
        'categorydeletedateyn': false,
        'categorydeletenote': null,
      });
      return null; // 성공
    } catch (e) {
      return '오류: $e';
    } finally {
      _submitting = false;
    }
  }
}
