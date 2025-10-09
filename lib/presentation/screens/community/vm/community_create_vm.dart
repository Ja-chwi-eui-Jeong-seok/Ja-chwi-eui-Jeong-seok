import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/presentation/providers/community_usecase_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';

final communityCreateVmProvider = ChangeNotifierProvider<CommunityCreateVm>(
  (ref) => CommunityCreateVm(ref),
);

class CommunityCreateVm extends ChangeNotifier {
  CommunityCreateVm(this.ref);
  final Ref ref;

  // ---[추가: 공통 상태]---
  bool _loading = false;
  bool get loading => _loading;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  String? _postId;
  String? get postId => _postId;

  // 화면 프리필/드래프트 값
  String _title = '';
  String get title => _title;

  String _content = '';
  String get content => _content;

  int? _categoryCode;
  int? get categoryCode => _categoryCode;

  int? _categoryDetailCode;
  int? get categoryDetailCode => _categoryDetailCode;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // 생성 모드
  void setModeCreate() {
    _isEdit = false;
    _postId = null;
    _title = '';
    _content = '';
    _categoryCode = null;
    _categoryDetailCode = null;
    notifyListeners();
  }

  Future<void> setModeEdit(String postId) async {
    _isEdit = true;
    _postId = postId;
    _setLoading(true);
    try {
      final getById = ref.read(getCommunityByIdProvider);
      final post = await getById(postId);
      if (post != null) {
        _title = post.communityName;
        _content = post.communityDetail;
        _categoryCode = post.categoryCode;
        _categoryDetailCode = post.categoryDetailCode;

        // 하위카테고리 칩 미리 보이게
        await ref
            .read(categoryVMProvider.notifier)
            .loadChildren(post.categoryCode);
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<String?> update({
    required String title,
    required String content,
    required int? categoryCode,
    required int? subCategoryCode,
  }) async {
    if (!_isEdit || _postId == null) return '잘못된 수정 요청입니다.';
    if (title.trim().isEmpty) return '제목을 입력하세요';
    if (content.trim().isEmpty) return '내용을 입력하세요';
    if (categoryCode == null || subCategoryCode == null) {
      return '카테고리와 세부 카테고리를 선택하세요';
    }

    _setSubmitting(true);
    try {
      final updateUsecase = ref.read(updateCommunityProvider);
      await updateUsecase.call(
        id: _postId!,
        patch: {
          'community_name': title.trim(),
          'community_detail': content.trim(),
          'category_code': categoryCode,
          'category_detail_code': subCategoryCode,
          // 'location': ... // 위치 변경 UI가 있으면 포함
          'community_update_date': DateTime.now(),
        },
      );
      return null; // 성공
    } catch (e) {
      return '오류: $e';
    } finally {
      _setSubmitting(false);
    }
  }

  // 화면 입력을 VM에 반영(컨트롤러 대신 동기화)
  void setDraft({
    String? title,
    String? content,
    int? categoryCode,
    int? categoryDetailCode,
  }) {
    if (title != null) _title = title;
    if (content != null) _content = content;
    if (categoryCode != null) _categoryCode = categoryCode;
    if (categoryDetailCode != null) _categoryDetailCode = categoryDetailCode;
    notifyListeners();
  }

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
