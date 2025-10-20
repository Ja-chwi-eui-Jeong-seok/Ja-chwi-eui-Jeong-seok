import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/screens/profile/bookmark_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/profile/my_post_detail_screen.dart';

class ProfileCardList extends ConsumerWidget {
  final String? filterType; // 'bookmark' or 'communitylist'
  final Map<String, dynamic>? extra;

  const ProfileCardList({super.key, this.filterType, required this.extra});

  String? get uid => extra?['uid'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uid == null) {
      return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (filterType == 'bookmark') _buildBookmarkSummary(context),
          if (filterType == 'communitylist') _buildCommunityList(context),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 북마크 카드
  // ---------------------------------------------------
  Widget _buildBookmarkSummary(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                '북마크 내역이 없습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          );
        }

        final communityBookmarks = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['type'] == 'BookmarkType.community';
        }).toList();

        if (communityBookmarks.isEmpty) return const SizedBox.shrink();

        DateTime? lastSaved;
        if (communityBookmarks.isNotEmpty) {
          lastSaved = (communityBookmarks
                  .map((doc) => (doc.data() as Map<String, dynamic>)['createdAt'] as Timestamp?)
                  .whereType<Timestamp>()
                  .map((ts) => ts.toDate())
                  .toList()
                ..sort((a, b) => b.compareTo(a)))
              .first;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookmarkDetailScreen(
                    bookmarkDocs: communityBookmarks,
                    extra: extra,
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark, color: Color(0xFFEDA85A)),
                          const SizedBox(width: 8),
                          const Text(
                            '커뮤니티 저장목록',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Center(
                            child: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (lastSaved != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(
                          ' 마지막 저장일: ${DateFormat('yyyy-MM-dd HH:mm').format(lastSaved)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------
  // CommunityList 카드 (Stream 기반)
  // ---------------------------------------------------
  Widget _buildCommunityList(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('communitylist')
        .where('create_user', isEqualTo: uid)
        .where('community_delete_yn', isEqualTo: false)
        .orderBy('community_create_date', descending: true)
        .limit(10)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('작성한 글이 없습니다.'),
          );
        }

        return Column(
          children: [
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['community_create_date'] as Timestamp?)?.toDate();
              final formattedDate =
                  createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt) : '';
              final location = data['location'] ?? '';
              final docId = doc.id;

              return Card(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
                child: SizedBox(
                  height: 64,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      data['community_name'] ?? '제목 없음',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$formattedDate | $location',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => context.push(
                      '/community-detail',
                      extra: {
                        'id': docId,
                        'extra': extra,
                      },
                    ),
                  ),
                ),
              );
            }).toList(),

            // 🔹 더보기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDA85A),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyPostDetailScreen(uid: uid!, extra: extra),
                    ),
                  );
                },
                child: const Text('더보기'),
              ),
            ),
          ],
        );
      },
    );
  }
}
