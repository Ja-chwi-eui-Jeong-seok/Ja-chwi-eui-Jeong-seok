import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/presentation/providers/community_usecase_provider.dart';

final communityCreateVmProvider = ChangeNotifierProvider<CommunityCreateVm>(
  (ref) => CommunityCreateVm(ref),
);

class CommunityCreateVm extends ChangeNotifier {
  CommunityCreateVm(this.ref);
  final Ref ref;
  bool _submitting = false;
  bool get submitting => _submitting;

  // UI에 변경 알림을 보내기 위한 setter
  void _setSubmitting(bool v) {
    _submitting = v;
    notifyListeners();
  }

  /// 성공: null 반환, 실패: 에러 메시지 반환
  Future<({String? error, String? newId})> submit({
    required String title,
    required String content,
    required int? categoryCode,
    required int? subCategoryCode,
    required String createUser,
    required String location,
  }) async {
    if (_submitting) return (error: '처리 중입니다', newId: null);
    if (title.trim().isEmpty) return (error: '제목을 입력하세요', newId: null);
    if (content.trim().isEmpty) return (error: '내용을 입력하세요', newId: null);
    if (categoryCode == null || subCategoryCode == null) {
      return (error: '카테고리와 세부 카테고리를 선택하세요', newId: null);
    }

    // _submitting = true;
    _setSubmitting(true);
    try {
      final c = Community(
        id: '',
        categoryCode: categoryCode,
        categoryDetailCode: subCategoryCode,
        communityName: title.trim(),
        communityDetail: content.trim(),
        createUser: createUser,
        location: location,
        communityCreateDate: DateTime.now(), // 서버시간으로 덮임
        communityUpdateDate: null,
        communityDeleteDate: null,
        communityDeleteYn: false,
        communityDeleteNote: '',
      );

      final newId = await ref.read(createCommunityProvider).call(c);
      return (error: null, newId: newId);
    } catch (e) {
      return (error: '오류: $e', newId: null);
    } finally {
      _setSubmitting(false);
    }
  }
}
