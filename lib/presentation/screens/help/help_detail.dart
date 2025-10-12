import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/help_provider.dart';
import 'package:ja_chwi/domain/entities/help_entity.dart';
import 'package:go_router/go_router.dart';
class HelpDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  final HelpEntity? help;

  const HelpDetailPage({super.key, this.help, this.extra});

  @override
  ConsumerState<HelpDetailPage> createState() => _HelpDetailPageState();
}

class _HelpDetailPageState extends ConsumerState<HelpDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String currentUserId; // extra['uid']로 초기화

  @override
  void initState() {
    super.initState();

    // extra에서 uid 가져오기, 없으면 빈 문자열
    currentUserId = widget.extra?['uid'] as String? ?? '';

    _titleController =
        TextEditingController(text: widget.help?.title ?? "");
    _contentController =
        TextEditingController(text: widget.help?.content ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.help != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "도움말 수정" : "도움말 등록"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final repo = ref.read(helpRepositoryProvider);
                await repo.softDeleteHelp(widget.help!.id, currentUserId);
                Navigator.pop(context);
              },
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "내용"),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(helpRepositoryProvider);

                if (isEditing) {
                  await repo.updateHelp(
                    widget.help!.copyWith(
                      title: _titleController.text,
                      content: _contentController.text,
                      updatedBy: currentUserId,
                      updatedAt: DateTime.now(),
                    ),
                  );
                } else {
                  await repo.addHelp(
                    HelpEntity(
                      id: "", // Firestore에서 자동 생성
                      title: _titleController.text,
                      content: _contentController.text,
                      createdBy: currentUserId,
                      createdAt: DateTime.now(),
                      updatedBy: currentUserId,
                      updatedAt: DateTime.now(),
                      deletedBy: null,
                      deletedAt: null,
                      deleteFlag: false,
                    ),
                  );
                }
                context.go('/admin', extra: widget.extra);
              },
              child: Text(isEditing ? "수정하기" : "등록하기"),
            )
          ],
        ),
      ),
    );
  }
}
