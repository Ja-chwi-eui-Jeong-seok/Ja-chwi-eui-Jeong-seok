import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/screens/profile/bookmark_detail_screen.dart';
import 'package:ja_chwi/presentation/screens/profile/my_post_detail_screen.dart';

class ProfileCardList extends ConsumerStatefulWidget {
  final String? filterType; // 'bookmark' or 'communitylist'
  final Map<String, dynamic>? extra;

  const ProfileCardList({super.key, this.filterType, this.extra});

  String? get uid => extra?['uid'];
  String? get col => extra?['color'];

  @override
  ConsumerState<ProfileCardList> createState() => _ProfileCardListState();
}

class _ProfileCardListState extends ConsumerState<ProfileCardList> {
  bool isLoading = false;
  List<DocumentSnapshot> communityList = [];

  @override
  void initState() {
    super.initState();
    print('🔹 initState - filterType: "${widget.filterType}"');
    if (widget.filterType == 'communitylist') {
      _fetchCommunityList();
    }
  }

  // ---------------------------------------------------
  // 탭 변경 시 호출
  // ---------------------------------------------------
  @override
  void didUpdateWidget(covariant ProfileCardList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filterType != oldWidget.filterType) {
      print('🔹 didUpdateWidget - filterType 변경: ${widget.filterType}');
      if (widget.filterType == 'communitylist') {
        _fetchCommunityList();
      }
    }
  }

  // ---------------------------------------------------
  // Firestore에서 최대 10개만 가져오기
  // ---------------------------------------------------
  Future<void> _fetchCommunityList() async {
    setState(() => isLoading = true);

    print('🔹 Fetch CommunityList 시작 - UID: ${widget.uid}');

    if (widget.uid == null) {
      print('❌ UID가 null입니다.');
      setState(() => isLoading = false);
      return;
    }

    try {
      final query = FirebaseFirestore.instance
          .collection('communitylist')
          .where('create_user', isEqualTo: widget.uid)
          .limit(10);

      print('🔹 Firestore 쿼리 준비 완료: $query');

      final snapshot = await query.get();

      print('🔹 Firestore 쿼리 완료 - 문서 수: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        print('📄 doc.id: ${doc.id}');
        print('    community_name: ${doc.data()['community_name']}');
        print('    create_date: ${doc.data()['community_create_date']}');
        print('    create_user: ${doc.data()['create_user']}');
      }

      setState(() {
        communityList = snapshot.docs;
      });
    } catch (e) {
      print('❌ Error fetching community list: $e');
    }

    setState(() => isLoading = false);
  }

  // ---------------------------------------------------
  // 북마크 요약 카드형 UI
  // ---------------------------------------------------
  Widget _buildBookmarkSummary() {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('bookmarks')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const SizedBox.shrink();

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

        String? col = widget.col;
        Color iconColor = Colors.grey;
        if (col != null && col.isNotEmpty) {
          try {
            iconColor = Color(int.parse('0xFF$col'));
          } catch (_) {
            iconColor = Colors.grey;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookmarkDetailScreen(bookmarkDocs: communityBookmarks),
                ),
              );
            },
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bookmark, color: iconColor),
                        const SizedBox(width: 8),
                        const Text(
                          '커뮤니티 저장목록',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                    if (lastSaved != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '마지막 저장: ${DateFormat('yyyy-MM-dd HH:mm').format(lastSaved)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
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
  // CommunityList 카드형 UI (최대 10개, 더보기 버튼)
  // ---------------------------------------------------
  Widget _buildCommunityList() {
    if (isLoading && communityList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (communityList.isEmpty && !isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text('작성한 글이 없습니다.'),
      );
    }
      String? col = widget.col;
        Color iconColor = Colors.grey;
        if (col != null && col.isNotEmpty) {
          try {
            iconColor = Color(int.parse('0xFF$col'));
          } catch (_) {
            iconColor = Colors.grey;
          }
        }

    return Column(
      children: [
        ...communityList.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = (data['community_create_date'] as Timestamp?)?.toDate();
          final formattedDate =
              createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt) : '';
          final location = data['location'] ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 15), // 좌우 12만큼 여백
            color: Colors.transparent, // 배경색 없애기
            elevation: 0, // 그림자 없애기
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey, width: 1), // 테두리 선
            ),
            child: ListTile(
              title: Text(data['community_name'] ?? '제목 없음'),
              subtitle: Text('$formattedDate | $location'),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16, // 아이콘 크기 조정 가능
                color: Colors.grey, // 원하는 색상
              ),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => MyPostDetailScreen(uid: widget.uid!),
                //   ),
                // );
              },
            ),
          );
        }).toList(),

        // 🔹 더보기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: iconColor, // 🔹 버튼 배경색
              foregroundColor: Colors.grey, // 🔹 텍스트/아이콘 색상
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // 모서리 둥글게
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // 버튼 내부 여백
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyPostDetailScreen(uid: widget.uid!),
                ),
              );
            },
            child: const Text('더보기'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uid == null) {
      return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.filterType == 'bookmark') _buildBookmarkSummary(),
          if (widget.filterType == 'communitylist') _buildCommunityList(),
        ],
      ),
    );
  }
}
