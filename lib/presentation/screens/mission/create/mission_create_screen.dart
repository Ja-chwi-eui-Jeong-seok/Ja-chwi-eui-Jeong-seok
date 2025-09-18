import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/create/widgets/description_input_field.dart';
import 'package:ja_chwi/presentation/screens/mission/create/widgets/photo_upload_section.dart';
import 'package:ja_chwi/presentation/screens/mission/create/widgets/public_toggle_switch.dart';

class MissionCreateScreen extends StatefulWidget {
  const MissionCreateScreen({super.key});

  @override
  State<MissionCreateScreen> createState() => _MissionCreateScreenState();
}

class _MissionCreateScreenState extends State<MissionCreateScreen> {
  String _missionTitle = '';
  bool _isPublic = true;
  List<String> _photos = [];
  final TextEditingController _descriptionController = TextEditingController();
  bool _isInitialized = false;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 위젯 트리에서 여러 번 호출될 수 있으므로, 초기화는 한 번만 수행
    if (_isInitialized) return;

    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      // 수정 모드
      _isEditing = true;
      final missionData = extra;
      _missionTitle = missionData['title'] as String? ?? '';
      _isPublic = missionData['isPublic'] as bool? ?? true;
      _photos = List<String>.from(missionData['photos'] as List? ?? []);
      _descriptionController.text = missionData['description'] as String? ?? '';
    } else if (extra is String) {
      // 생성 모드 (템플릿 제목 전달)
      _missionTitle = extra;
    } else {
      // 기본 생성 모드 (임시)
      _missionTitle = '삼시세끼 다 먹기';
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
                onAddPhoto: () {
                  setState(() {
                    _photos.add(
                      'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}',
                    );
                  });
                },
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
          onPressed: () {
            // TODO: 미션 완료 데이터 처리 로직
            context.pop();
          },
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
          child: Text(
            _isEditing ? '수정하기' : '확인',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
