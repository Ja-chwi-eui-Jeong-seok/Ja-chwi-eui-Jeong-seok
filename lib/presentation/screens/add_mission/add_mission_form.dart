import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/add_mission_providers.dart';

class AddMissionForm extends ConsumerStatefulWidget {
  const AddMissionForm({super.key});

  @override
  ConsumerState<AddMissionForm> createState() => _AddMissionFormState();
}

class _AddMissionFormState extends ConsumerState<AddMissionForm> {
  final _tagController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addMission() async {
    if (_tagController.text.isEmpty || _titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(addMissionRepositoryProvider).addMission(
            _tagController.text.trim(),
            _titleController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('미션이 추가되었습니다.')),
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
      appBar: AppBar(title: const Text('Add Mission')),
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
                    onPressed: _addMission,
                    icon: const Icon(Icons.add),
                    label: const Text('미션 추가'),
                  ),
          ],
        ),
      ),
    );
  }
}
