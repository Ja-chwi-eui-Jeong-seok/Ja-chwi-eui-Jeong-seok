import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/create/widgets/description_input_field.dart';
import 'package:ja_chwi/presentation/screens/mission/create/widgets/photo_upload_section.dart';
import 'package:ja_chwi/presentation/screens/mission/create/widgets/public_toggle_switch.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart'; // missionRepositoryProvider를 위해 추가

class MissionCreateScreen extends ConsumerStatefulWidget {
  const MissionCreateScreen({super.key});

  @override
  ConsumerState<MissionCreateScreen> createState() =>
      _MissionCreateScreenState();
}

class _MissionCreateScreenState extends ConsumerState<MissionCreateScreen> {
  String _missionTitle = '';
  List<String> _tags = [];
  bool _isPublic = true;
  List<dynamic> _photos = []; // String (URL) or XFile (local)
  final TextEditingController _descriptionController = TextEditingController();
  bool _isInitialized = false;
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 위젯 트리에서 여러 번 호출될 수 있으므로, 초기화는 한 번만 수행
    if (_isInitialized) {
      return;
    }
    _initializeFromExtra();
    _isInitialized = true;
  }

  void _initializeFromExtra() {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      // 수정 모드
      _isEditing = true;
      final missionData = extra;
      setState(() {
        _missionTitle = missionData['title'] as String? ?? '';
        _tags = List<String>.from(missionData['tags'] as List? ?? []);
        _isPublic = missionData['isPublic'] as bool? ?? true;
        _photos = List<dynamic>.from(missionData['photos'] as List? ?? []);
        _descriptionController.text =
            missionData['description'] as String? ?? '';
      });
    } else if (extra is String) {
      // 생성 모드 (템플릿 제목 전달)
      _missionTitle = extra;
      // 생성 모드일 때, 오늘의 미션 태그를 가져옵니다.
      ref.read(todayMissionProvider.future).then((mission) {
        if (mounted) setState(() => _tags = mission.tags);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    if (_photos.length >= 5) {
      return;
    }
    final pickImagesUseCase = ref.read(pickImagesUseCaseProvider);
    final pickedFiles = await pickImagesUseCase.execute();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        int availableSlots = 5 - _photos.length;
        _photos.addAll(pickedFiles.take(availableSlots));
      });
    }
  }

  Future<void> _submitMission() async {
    if (_isSubmitting) {
      return;
    }

    if (_photos.isEmpty) {
      _showSnackBar('사진을 1장 이상 추가해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    final missionRepository = ref.read(missionRepositoryProvider);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      // 앱 정책상 사용자는 항상 로그인 되어 있어야 합니다.
      // user가 null인 경우는 예외적인 상황으로 간주하고 에러를 발생시킵니다.
      if (user == null) {
        throw Exception("사용자 인증 정보가 없습니다. 다시 로그인해주세요.");
      }

      // 오늘 날짜로 이미 완료한 미션이 있는지 확인 (수정 모드가 아닐 때만)
      if (!_isEditing) {
        if (await missionRepository.hasCompletedMissionToday(user.uid)) {
          _showSnackBar('오늘의 미션은 이미 완료했습니다!');
          if (mounted) {
            setState(() => _isSubmitting = false);
          }
          return;
        }
      }

      final photoUrls = await missionRepository.uploadPhotos(user.uid, _photos);

      if (_isEditing) {
        // 수정 모드: update 사용
        await missionRepository.updateMission(
          userId: user.uid,
          missionData: {
            'title': _missionTitle,
            'isPublic': _isPublic,
            'photos': photoUrls,
            'description': _descriptionController.text,
            'tags': _tags,
          },
        );
      } else {
        // 생성 모드: set 사용
        await missionRepository.createMission(
          userId: user.uid,
          missionData: {
            'title': _missionTitle,
            'isPublic': _isPublic,
            'photos': photoUrls,
            'description': _descriptionController.text,
            'tags': _tags,
          },
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      // 에러 처리 (예: 스낵바 표시)
      debugPrint('미션 제출 오류: $e');
      _showSnackBar('업로드에 실패했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _missionTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '미션을 수행하고 인증 사진을 남겨주세요!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 24),
              PhotoUploadSection(
                photos: _photos,
                onAddPhoto: _addPhotos,
                onRemovePhoto: (index) {
                  setState(() {
                    _photos.removeAt(index);
                  });
                },
              ),
              const SizedBox(height: 24),
              PublicToggleSwitch(
                isPublic: _isPublic,
                onToggle: () => setState(() => _isPublic = !_isPublic),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              DescriptionInputField(controller: _descriptionController),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitMission,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.grey.shade300),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : Text(
                  _isEditing ? '수정하기' : '확인',
                  style: const TextStyle(fontSize: 18),
                ),
        ),
      ),
    );
  }
}
