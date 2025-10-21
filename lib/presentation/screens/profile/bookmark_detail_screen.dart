import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookmarkDetailScreen extends StatefulWidget {
  final String uid; // uid 전달
  final Map<String, dynamic>? extra;

  const BookmarkDetailScreen({super.key, required this.uid, this.extra});

  @override
  State<BookmarkDetailScreen> createState() => _BookmarkDetailScreenState();
}

class _BookmarkDetailScreenState extends State<BookmarkDetailScreen> {
  DateTimeRange? selectedDateRange;
  String? selectedLocation;

  /// 날짜 선택
  Future<void> pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDateRange,
    );
    if (range != null) setState(() => selectedDateRange = range);
  }

  /// 지역 선택
  Future<void> pickLocation() async {
    final loc = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController(text: selectedLocation ?? '');
        return AlertDialog(
          title: const Text('지역 입력'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('취소')),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('확인')),
          ],
        );
      },
    );
    if (loc != null) setState(() => selectedLocation = loc);
  }

  /// 필터 초기화
  void resetFilters() {
    setState(() {
      selectedDateRange = null;
      selectedLocation = null;
    });
  }

  /// 북마크 스트림
  Stream<List<QueryDocumentSnapshot>> getBookmarkStream() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('bookmarks');

    if (selectedDateRange != null) {
      final startTs = Timestamp.fromDate(selectedDateRange!.start);
      final endTs =
          Timestamp.fromDate(selectedDateRange!.end.add(const Duration(days: 1)));
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: startTs)
          .where('createdAt', isLessThan: endTs);
    }

    return query.snapshots().map((snap) => snap.docs);
  }

  /// 커뮤니티 + 프로필 병합
  Future<List<Map<String, dynamic>>> enrichBookmarks(
      List<QueryDocumentSnapshot> bookmarkDocs) async {
    final firestore = FirebaseFirestore.instance;

    final futures = bookmarkDocs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final communityId = data['id'];
      if (communityId == null) return null;

      final communityDoc =
          await firestore.collection('communitylist').doc(communityId).get();
      if (!communityDoc.exists) return null;
      final communityData = communityDoc.data()!;
      if (communityData['community_delete_yn'] == true) return null;

      final createUser = communityData['create_user'];
      String? nickname;
      String? thumbUrl;

      if (createUser != null) {
        final profileDoc =
            await firestore.collection('profiles').doc(createUser).get();
        if (profileDoc.exists) {
          nickname = profileDoc.data()?['nickname'];
          thumbUrl = profileDoc.data()?['thumbUrl'];
        }
      }

      final Timestamp? bookmarkCreatedAt = data['createdAt'] as Timestamp?;

      // 🔹 지역 필터
      final location = communityData['location'] ?? '';
      if (selectedLocation != null &&
          selectedLocation!.isNotEmpty &&
          !location.contains(selectedLocation!)) {
        return null;
      }

      return {
        'id': communityId,
        'community_name': communityData['community_name'] ?? '제목 없음',
        'community_detail': communityData['community_detail'] ?? '',
        'location': location,
        'createdAt': bookmarkCreatedAt,
        'nickname': nickname ?? '알 수 없음',
        'thumbUrl': thumbUrl,
      };
    });

    final results = await Future.wait(futures);
    return results.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장 목록'),
        actions: [
          IconButton(
              icon: const Icon(Icons.autorenew_outlined),
              tooltip: '필터 초기화',
              onPressed: resetFilters),
          IconButton(
              icon: const Icon(Icons.date_range),
              tooltip: '기간 필터',
              onPressed: pickDateRange),
          IconButton(
              icon: const Icon(Icons.location_on),
              tooltip: '지역 필터',
              onPressed: pickLocation),
        ],
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: getBookmarkStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: enrichBookmarks(snapshot.data!),
            builder: (context, enrichedSnapshot) {
              if (!enrichedSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = enrichedSnapshot.data!;
              if (docs.isEmpty) {
                return const Center(
                    child: Text('조건에 맞는 북마크가 없습니다.',
                        style: TextStyle(fontSize: 16)));
              }

              return Column(
                children: [
                  // 상단 필터
                  Container(
                    width: double.infinity,
                    color: Color(0xFFF6CE1A).withValues(alpha: 0.2),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('커뮤니티 저장목록 총 ${docs.length}개',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        if (selectedLocation != null &&
                            selectedLocation!.isNotEmpty)
                          Text('지역 필터: ${selectedLocation!}',
                              style: const TextStyle(color: Colors.grey)),
                        if (selectedDateRange != null)
                          Text(
                              '기간: ${DateFormat('yy.MM.dd').format(selectedDateRange!.start)} ~ '
                              '${DateFormat('yy.MM.dd').format(selectedDateRange!.end)}',
                              style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];
                        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                        final formattedDate = createdAt != null
                            ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                            : '';
                        final name = data['community_name'] ?? '제목 없음';
                        //final detail = data['community_detail'] ?? '';
                        final location = data['location'] ?? '';
                        final nickname = data['nickname'] ?? '';
                        final thumbUrl = data['thumbUrl'];
                        final id = data['id'] ?? '';

                        return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  thumbUrl != null ? AssetImage(thumbUrl) : null,
                              child: thumbUrl == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            title: Text(name),
                            subtitle: Text(
                              '$nickname ($location)\n저장일자:$formattedDate',
                              style: const TextStyle(height: 1.3),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.push('/community-detail',
                                extra: {'id': id, 'extra': widget.extra}),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
