import 'package:flutter/material.dart';
import 'package:ja_chwi/data/datasources/block_datasource.dart';
import 'package:ja_chwi/data/repositories/block_repository_impl.dart';

class BlockUserPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const BlockUserPage({super.key, this.extra});

  @override
  State<BlockUserPage> createState() => _BlockUserPageState();
}

class _BlockUserPageState extends State<BlockUserPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  final blockRepository = BlockRepositoryImpl(
    remoteDataSource: FirebaseBlockDataSource(),
  );

  late final String myUid; // 🔹 extra에서 가져올 UID 저장 변수
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 🔹 extra에서 uid 추출
    myUid = widget.extra?['uid'] ?? 'unknown';
  }

  Future<void> _blockUser() async {
    final targetUid = _userIdController.text.trim();
    final reason = _reasonController.text.trim();

    if (targetUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차단할 사용자 UID를 입력하세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await blockRepository.remoteDataSource.blockUser(
        userId: targetUid,
        blockedBy: myUid,
        reason: reason.isEmpty ? null : reason,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차단 완료')),
      );

      _userIdController.clear();
      _reasonController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('차단 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 차단')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: '차단할 사용자 UID',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: '차단 사유 (선택)',
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _blockUser,
                    icon: const Icon(Icons.block),
                    label: const Text('차단하기'),
                  ),
          ],
        ),
      ),
    );
  }
}
