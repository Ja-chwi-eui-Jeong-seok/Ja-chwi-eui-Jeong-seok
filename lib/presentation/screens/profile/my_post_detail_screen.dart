import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  final String uid;

  const MyPostDetailScreen({super.key, required this.uid, required this.extra});

  @override
  State<MyPostDetailScreen> createState() => _MyPostDetailScreenState();
}

class _MyPostDetailScreenState extends State<MyPostDetailScreen> {
  DateTimeRange? selectedDateRange;
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    // Firestore 쿼리 생성
    Query collectionQuery = FirebaseFirestore.instance
        .collection('communitylist')
        .where('create_user', isEqualTo: widget.uid)
        .where('community_delete_yn', isEqualTo: false)
        .orderBy('community_create_date', descending: true)
        .limit(20);

    // 날짜 필터 적용
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

      collectionQuery = collectionQuery
          .where('community_create_date', isGreaterThanOrEqualTo: start)
          .where('community_create_date', isLessThanOrEqualTo: end);
    }

    // StreamBuilder 사용
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 글 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.autorenew_outlined),
            tooltip: '필터 초기화',
            onPressed: () {
              setState(() {
                selectedDateRange = null;
                selectedLocation = null;
              });
            },
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
          // 🔹 필터 표시 영역
          Container(
            width: double.infinity,
            color: const Color(0xFFF6CE1A).withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: collectionQuery.snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text('커뮤니티 목록 총 $count개',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold));
                  },
                ),
                if (selectedLocation != null && selectedLocation!.isNotEmpty)
                  Text('지역: ${selectedLocation!}',
                      style: const TextStyle(color: Colors.grey)),
                if (selectedDateRange != null)
                  Text(
                    '기간: ${DateFormat('yy.MM.dd').format(selectedDateRange!.start)} ~ ${DateFormat('yy.MM.dd').format(selectedDateRange!.end)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionQuery.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 지역 필터 적용
                var docs = snapshot.data!.docs;
                if (selectedLocation != null && selectedLocation!.isNotEmpty) {
                  docs = docs.where((doc) {
                    final location = doc['location'] ?? '';
                    return location.contains(selectedLocation!);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('조건에 맞는 글이 없습니다.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final communityCreateDate =
                        (data['community_create_date'] as Timestamp?)?.toDate();
                    final formattedDate = communityCreateDate != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(communityCreateDate)
                        : '';
                    final location = data['location'] ?? '';
                    final title = data['community_name'] ?? '제목 없음';
                    final docId = docs[index].id;

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text('$formattedDate | $location'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () => context.push(
                          '/community-detail',
                          extra: {
                            'id': docId,
                            'extra': widget.extra,
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 선택
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
    }
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
    }
  }
}
