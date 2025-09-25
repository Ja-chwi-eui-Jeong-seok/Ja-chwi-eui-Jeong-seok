import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/presentation/providers/community_usecase_provider.dart';

final communityCreateVmProvider = Provider<CommunityCreateVm>(
  (ref) => CommunityCreateVm(ref),
);

class CommunityCreateVm {
  CommunityCreateVm(this.ref);
  final Ref ref;
  bool _submitting = false;
  bool get submitting => _submitting;

  /// 성공: null 반환, 실패: 에러 메시지 반환
  Future<String?> submit({
    required String title,
    required String content,
    required int? categoryCode,
    required int? subCategoryCode,
  }) async {
    if (_submitting) return '처리 중입니다';
    if (title.trim().isEmpty) return '제목을 입력하세요';
    if (content.trim().isEmpty) return '내용을 입력하세요';
    if (categoryCode == null || subCategoryCode == null)
      return '카테고리와 세부 카테고리를 선택하세요';

    _submitting = true;
    try {
      final c = Community(
        id: '',
        categoryCode: categoryCode,
        categoryDetailCode: subCategoryCode,
        communityName: title.trim(),
        communityDetail: content.trim(),
        createUser: '이영상',
        location: '동작구',
        communityCreateDate: DateTime.now(),
        communityUpdateDate: null,
        communityDeleteDate: null,
        communityDeleteYn: false,
        communityDeleteNote: '',
      );
      final id = await ref.read(createCommunityProvider).call(c);
      //TODO:상세이동
      return null;
    } catch (e) {
      return '오류: $e';
    } finally {
      _submitting = false;
    }
  }
}
