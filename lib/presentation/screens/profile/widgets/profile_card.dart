import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileCardList extends ConsumerWidget {
  final String? uid;
  final String? filterType; // 'bookmark' or 'myPosts'

  const ProfileCardList({super.key, this.uid, this.filterType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uid == null) {
      return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
    }

    final collection = filterType == 'bookmark'
        ? 'bookmarks'
        : 'posts'; // ✅ 필터별로 다른 Firestore 컬렉션

    final stream = FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(uid)
        .collection(collection)
        .snapshots();

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('데이터가 없습니다.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return ListTile(
              title: Text(data['title'] ?? '제목 없음'),
              subtitle: Text(data['createdAt']?.toString() ?? ''),
            );
          },
        );
      },
    );
  }
}