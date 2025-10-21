import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MyReportsPage extends StatefulWidget {
  final Map<String, dynamic> extra;

  const MyReportsPage({super.key, required this.extra});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // UID -> 닉네임 캐시
  final Map<String, String> nicknameCache = {};
  // UID -> thumbUrl 캐시
  final Map<String, String?> thumbCache = {};

  // 닉네임 + thumbUrl 가져오기
  Future<void> fetchProfile(String uid) async {
    if (nicknameCache.containsKey(uid)) return;

    final doc = await firestore.collection('profiles').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      nicknameCache[uid] = data?['nickname'] ?? 'Unknown';
      thumbCache[uid] = data?['thumbUrl'];
    } else {
      nicknameCache[uid] = 'Unknown';
      thumbCache[uid] = null;
    }
  }

  // 여러 UID 캐시 로딩
  Future<void> preloadProfiles(List<String> uids) async {
    final futures = uids.map((uid) => fetchProfile(uid));
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = widget.extra['uid'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 신고한 내역'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/settings', extra: widget.extra);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('reports')
            .where('userId', isEqualTo: myUid) // 내가 신고한 내역만 필터
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final reports = snapshot.data!.docs;
          if (reports.isEmpty) {
            return const Center(
              child: Text(
                '신고한 내역이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          // targetId 기준 그룹화 + 전체 UID 수집
          Map<String, List<Map<String, dynamic>>> groupedReports = {};
          final allUids = <String>{};

          for (var doc in reports) {
            final data = doc.data() as Map<String, dynamic>;
            final targetId = data['targetId'] ?? '';
            groupedReports.putIfAbsent(targetId, () => []).add(data);
            allUids.add(targetId);
          }

          return FutureBuilder(
            future: preloadProfiles(allUids.toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final cards = groupedReports.entries.map((entry) {
                final targetId = entry.key;
                final reportsList = entry.value;

                final totalReports = reportsList.length;
                final targetNickname = nicknameCache[targetId] ?? 'Unknown';
                final targetThumbUrl = thumbCache[targetId];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    collapsedBackgroundColor: Colors.grey[100],
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: targetThumbUrl != null
                                ? Image.asset(targetThumbUrl, fit: BoxFit.cover)
                                : Image.asset('assets/images/m_profile/m_black.png', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          targetNickname,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '신고 횟수: $totalReports',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    children: reportsList.map((report) {
                      final createdAt = report['createdAt'] != null
                          ? (report['createdAt'] as Timestamp).toDate()
                          : null;
                      final formattedDate = createdAt != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                          : '';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '사유: ${report['reason'] ?? ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList();

              return ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                children: cards,
              );
            },
          );
        },
      ),
    );
  }
}
