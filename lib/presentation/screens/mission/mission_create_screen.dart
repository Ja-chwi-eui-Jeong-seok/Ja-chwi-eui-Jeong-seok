import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/description_input_field.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/photo_upload_section.dart';
import 'package:ja_chwi/presentation/screens/mission/widgets/public_toggle_switch.dart';

class MissionCreateScreen extends StatefulWidget {
  final String? missionTitle;

  const MissionCreateScreen({super.key, this.missionTitle});

  @override
  State<MissionCreateScreen> createState() => _MissionCreateScreenState();
}

class _MissionCreateScreenState extends State<MissionCreateScreen> {
  bool _isPublic = true;
  final List<String> _photos = []; // 사진 업로드 시뮬레이션을 위한 임시 리스트
  final TextEditingController _descriptionController = TextEditingController();

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
                widget.missionTitle ?? '미션 인증',
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
                  setState(() => _photos.add('placeholder'));
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
          child: const Text('확인', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
