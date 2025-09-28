import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/data/datasources/block_datasource.dart';
import 'package:ja_chwi/data/repositories/block_repository_impl.dart';
import 'package:ja_chwi/domain/entities/block_entity.dart';

class MyBlockedUsersPage extends StatefulWidget {
  final String myUid; // 현재 로그인한 UID

  const MyBlockedUsersPage({super.key, required this.myUid});

  @override
  State<MyBlockedUsersPage> createState() => _MyBlockedUsersPageState();
}

class _MyBlockedUsersPageState extends State<MyBlockedUsersPage> {
  late Future<List<BlockEntity>> _blockedUsers;

 // Repository 인스턴스 생성
  final blockRepository = BlockRepositoryImpl(
    remoteDataSource: FirebaseBlockDataSource(),
  );
  
  @override
  void initState() {
    super.initState();
    _blockedUsers = blockRepository.fetchBlockedUsersByMe(widget.myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 차단한 사람"),
        leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.pop(), // 직전 화면으로 이동
        ),
      ),
      body: FutureBuilder<List<BlockEntity>>(
        future: _blockedUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("차단한 사람이 없습니다."));
          }
          final blocks = snapshot.data!;
          return ListView.builder(
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              final block = blocks[index];
              return ListTile(
                title: Text(block.userId),
                subtitle: Text(block.reason ?? "차단 사유 없음"),
                trailing: Text(
                  "${block.createdAt.year}-${block.createdAt.month}-${block.createdAt.day}"
                ),
              );
            },
          );
        },
      ),
    );
  }
}
