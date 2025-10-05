import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/add_mission_entity.dart';
import 'package:ja_chwi/presentation/providers/add_mission_providers.dart';

class EditMissionForm extends ConsumerStatefulWidget {
  final AddMissionEntity mission;

  const EditMissionForm({super.key, required this.mission});

  @override
  ConsumerState<EditMissionForm> createState() => _EditMissionFormState();
}

class _EditMissionFormState extends ConsumerState<EditMissionForm> {
  late TextEditingController _tagController;
  late TextEditingController _titleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.mission.missionTag);
    _titleController = TextEditingController(text: widget.mission.missionTitle);
  }

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _updateMission() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(addMissionRepositoryProvider).updateMission(
            widget.mission.id!,
            _tagController.text.trim(),
            _titleController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('미션이 수정되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Mission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _tagController, decoration: const InputDecoration(labelText: '미션 태그')),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: '미션 제목')),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _updateMission,
                    icon: const Icon(Icons.edit),
                    label: const Text('수정 완료'),
                  ),
          ],
        ),
      ),
    );
  }
}
