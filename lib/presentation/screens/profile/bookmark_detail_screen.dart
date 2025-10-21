import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookmarkDetailScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> bookmarkDocs;

  const BookmarkDetailScreen({super.key, required this.bookmarkDocs});

  @override
  State<BookmarkDetailScreen> createState() => _BookmarkDetailScreenState();
}

class _BookmarkDetailScreenState extends State<BookmarkDetailScreen> {
  DateTimeRange? selectedDateRange;
  String? selectedLocation;
  bool isLoading = true;
  List<Map<String, dynamic>> enrichedBookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  /// Firestore에서 필터 적용 (북마크 생성일 기준)
  Future<void> _loadCommunityData() async {
    setState(() {
      isLoading = true;
      enrichedBookmarks = []; // 초기화
    });

    final firestore = FirebaseFirestore.instance;
    try {
      final futures = widget.bookmarkDocs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final communityId = data['id'];
        if (communityId == null) return null;

        // 🔹 북마크 생성일 기준 필터
        final Timestamp? bookmarkCreatedAt = data['createdAt'] as Timestamp?;
        if (selectedDateRange != null && bookmarkCreatedAt != null) {
          final startTs = Timestamp.fromDate(selectedDateRange!.start);
          final endTs = Timestamp.fromDate(
              selectedDateRange!.end.add(const Duration(days: 1)));
          if (bookmarkCreatedAt.compareTo(startTs) < 0 ||
              bookmarkCreatedAt.compareTo(endTs) >= 0) {
            return null;
          }
        }

        final communityDoc =
            await firestore.collection('communitylist').doc(communityId).get();
        if (!communityDoc.exists) return null;

        final communityData = communityDoc.data()!;
        final createUser = communityData['create_user'];
        final String location = communityData['location'] ?? '';

        // 🔹 지역 필터 (문자열 포함)
        if (selectedLocation != null && selectedLocation!.isNotEmpty) {
          if (!location.contains(selectedLocation!)) return null;
        }

        // 🔹 프로필 조회
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

        return {
          'id': communityId,
          'community_name': communityData['community_name'] ?? '제목 없음',
          'location': location,
          'createdAt': bookmarkCreatedAt,
          'nickname': nickname ?? '알 수 없음',
          'thumbUrl': thumbUrl,
        };
      }).toList();

      final results = await Future.wait(futures);
      if (!mounted) return;

      setState(() {
        enrichedBookmarks = results.whereType<Map<String, dynamic>>().toList();
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('❗ 전체 로딩 오류: $e\n$stack');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  /// 날짜 선택 후 즉시 조회
  Future<void> pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDateRange,
    );

    if (range != null) {
      setState(() {
        selectedDateRange = range;
        isLoading = true;
      });

      await _loadCommunityData();
    }
  }

  /// 지역 선택 후 즉시 조회
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
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (loc != null) {
      setState(() => selectedLocation = loc);
      await _loadCommunityData();
    }
  }

  /// 필터 초기화
  Future<void> resetFilters() async {
    setState(() {
      selectedDateRange = null;
      selectedLocation = null;
    });
    await _loadCommunityData();
  }

  @override
  Widget build(BuildContext context) {
    final docs = enrichedBookmarks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('저장 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '필터 초기화',
            onPressed: resetFilters,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: '기간 필터',
            onPressed: pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: '지역 필터',
            onPressed: pickLocation,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 상단 필터 표시
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('커뮤니티 저장목록 총 ${docs.length}개',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (selectedLocation != null && selectedLocation!.isNotEmpty)
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
                  child: docs.isEmpty
                      ? const Center(
                          child: Text(
                            '조건에 맞는 북마크가 없습니다.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index];
                            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                            final formattedDate = createdAt != null
                                ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                                : '';
                            final name = data['community_name'] ?? '제목 없음';
                            final location = data['location'] ?? '';
                            final nickname = data['nickname'] ?? '';
                            final thumbUrl = data['thumbUrl'];

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
                                  '$nickname ($location)\n 저장일자:$formattedDate',
                                  style: const TextStyle(height: 1.3),
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
