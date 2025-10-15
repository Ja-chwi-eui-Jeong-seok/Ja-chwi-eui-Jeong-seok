import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPostDetailScreen extends StatefulWidget {
  final String uid;

  const MyPostDetailScreen({super.key, required this.uid});

  @override
  State<MyPostDetailScreen> createState() => _MyPostDetailScreenState();
}

class _MyPostDetailScreenState extends State<MyPostDetailScreen> {
  final int _limit = 20;
  final List<DocumentSnapshot> _posts = [];
  DocumentSnapshot? _lastDocument;

  bool _isLoading = false;
  bool _hasMore = true;

  DateTimeRange? selectedDateRange;
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchPosts(initial: true);
  }

  /// Firestore 조회 + 필터 적용
  Future<void> _fetchPosts({bool initial = false}) async {
    if (_isLoading) return;
    if (!_hasMore && !initial) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('communitylist')
        .where('create_user', isEqualTo: widget.uid)
        .where('community_delete_yn', isEqualTo: false)
        .orderBy('community_create_date', descending: true)
        .limit(_limit);

    // 날짜 필터
    if (selectedDateRange != null) {
      final start = Timestamp.fromDate(DateTime(
        selectedDateRange!.start.year,
        selectedDateRange!.start.month,
        selectedDateRange!.start.day,
        0, 0, 0,
      ));
      final end = Timestamp.fromDate(DateTime(
        selectedDateRange!.end.year,
        selectedDateRange!.end.month,
        selectedDateRange!.end.day,
        23, 59, 59,
      ));
      query = query
          .where('community_create_date', isGreaterThanOrEqualTo: start)
          .where('community_create_date', isLessThanOrEqualTo: end);
    }

    // 데이터 가져오기
    final snapshot = await query.get();

    // 지역 필터 (Bookmark 방식: 문자열 포함)
    final filteredDocs = snapshot.docs.where((doc) {
      if (selectedLocation != null && selectedLocation!.isNotEmpty) {
        final location = doc['location'] ?? '';
        return location.contains(selectedLocation!);
      }
      return true;
    }).toList();

    if (initial) {
      _posts.clear();
      _hasMore = true;
      _lastDocument = null;
    }

    if (filteredDocs.isNotEmpty) {
      _lastDocument = filteredDocs.last;
      _posts.addAll(filteredDocs);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  /// 날짜 선택 후 즉시 재조회
  Future<void> pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDateRange,
    );

    if (range != null) {
      setState(() => selectedDateRange = range);
      await _fetchPosts(initial: true); // 바로 재조회
    }
  }

  /// 지역 선택 (문자열 포함)
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
      await _fetchPosts(initial: true); // 바로 재조회
    }
  }

  /// 필터 초기화
  Future<void> resetFilters() async {
    setState(() {
      selectedDateRange = null;
      selectedLocation = null;
    });
    await _fetchPosts(initial: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 글 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '필터 초기화',
            onPressed: resetFilters,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: '기간 선택',
            onPressed: pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: '지역 필터',
            onPressed: pickLocation,
          ),
        ],
      ),
 body: Column(
  children: [
    // 🔹 필터 표시 영역 (선택된 날짜/지역)
    if (selectedDateRange != null || (selectedLocation != null && selectedLocation!.isNotEmpty))
      Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedLocation != null && selectedLocation!.isNotEmpty)
              Text('지역: ${selectedLocation!}', style: const TextStyle(color: Colors.grey)),
            if (selectedDateRange != null)
              Text(
                  '기간: ${DateFormat('yy.MM.dd').format(selectedDateRange!.start)} ~ '
                  '${DateFormat('yy.MM.dd').format(selectedDateRange!.end)}',
                  style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    
    Expanded(
      child: _isLoading && _posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('조건에 맞는 글이 없습니다.'))
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final data = _posts[index].data() as Map<String, dynamic>;
                    final community_create_date =
                        (data['community_create_date'] as Timestamp?)?.toDate();
                    final formattedDate = community_create_date != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(community_create_date)
                        : '';
                    final location = data['location'] ?? '';
                    final title = data['community_name'] ?? '제목 없음';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text('$formattedDate | $location'),
                        onTap: () {},
                      ),
                    );
                  },
                ),
    ),
    if (_hasMore)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _fetchPosts(initial: false),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('더보기'),
        ),
      ),
  ],
),

    );
  }
}
