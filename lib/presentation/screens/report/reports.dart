import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ReportsPage extends StatefulWidget {
  final Map<String, dynamic> extra;

  const ReportsPage({super.key, required this.extra});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 신고 내역 집계'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/admin', extra: widget.extra);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('reports').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final reports = snapshot.data!.docs;

          // targetId 기준 그룹화 + 전체 UID 수집
          Map<String, List<Map<String, dynamic>>> groupedReports = {};
          final allUids = <String>{};

          for (var doc in reports) {
            final data = doc.data() as Map<String, dynamic>;
            final targetId = data['targetId'] ?? '';
            final userId = data['userId'] ?? '';
            groupedReports.putIfAbsent(targetId, () => []).add(data);

            allUids.add(targetId);
            allUids.add(userId);
          }

          // 캐시 로딩
          return FutureBuilder(
            future: preloadProfiles(allUids.toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final cards = groupedReports.entries.map((entry) {
                final targetId = entry.key;
                final reportsList = entry.value;

                // 신고자 수 및 총 신고 횟수 계산
                final uniqueUsers = reportsList.map((e) => e['userId']).toSet().length;
                final totalReports = reportsList.length;

                final targetNickname = nicknameCache[targetId] ?? 'Unknown';
                final targetThumbUrl = thumbCache[targetId];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetNickname,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              targetId, // 다음 줄에 targetId
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '신고자 수: $uniqueUsers | 총 신고 횟수: $totalReports',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    children: reportsList.map((report) {
                      final createdAt = report['createdAt'] != null
                          ? (report['createdAt'] as Timestamp).toDate()
                          : null;
                      final formattedDate = createdAt != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                          : '';
                      final userId = report['userId'] ?? '';
                      final userNickname = nicknameCache[userId] ?? 'Unknown';
                      final userThumbUrl = thumbCache[userId];

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: userThumbUrl != null
                                    ? Image.asset(userThumbUrl, fit: BoxFit.cover)
                                    : Image.asset('assets/images/m_profile/m_black.png', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userNickname,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('사유: ${report['reason'] ?? ''}'),
                                ],
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList();
              return ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                children: cards,
              );
            },
          );
        },
      ),
    );
  }
}
