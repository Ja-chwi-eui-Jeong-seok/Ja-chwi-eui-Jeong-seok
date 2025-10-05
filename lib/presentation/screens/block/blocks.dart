import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlocksPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const BlocksPage({super.key, this.extra});

  @override
  State<BlocksPage> createState() => _BlocksPageState();
}

class _BlocksPageState extends State<BlocksPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _allBlocks;

  @override
  void initState() {
    super.initState();
    _allBlocks = fetchAllBlocks();
  }

  /// 전체 차단 내역 조회
  Future<List<Map<String, dynamic>>> fetchAllBlocks() async {
    final snapshot = await firestore
        .collection('blocks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'userId': data['userId'] ?? '',
        'blockedBy': data['blockedBy'] ?? '',
        'reason': data['reason'] ?? '',
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      };
    }).toList();
  }

  /// uid → {nickname, thumbUrl} 매핑
  Future<Map<String, Map<String, String>>> fetchProfiles(Set<String> uids) async {
    final Map<String, Map<String, String>> map = {};
    for (var uid in uids) {
      final doc = await firestore.collection('profiles').doc(uid).get();
      map[uid] = doc.exists
          ? {
              'nickname': doc.data()?['nickname'] ?? uid,
              'thumbUrl': doc.data()?['thumbUrl'] ?? '',
            }
          : {
              'nickname': uid,
              'thumbUrl': '',
            };
    }
    return map;
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("전체 차단 내역"), 
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              context.go('/admin', extra: widget.extra);
            },
          ),),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _allBlocks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          }

          final allBlocks = snapshot.data ?? [];
          if (allBlocks.isEmpty) {
            return const Center(child: Text("등록된 차단 내역이 없습니다."));
          }

          // userId별 그룹화
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (var block in allBlocks) {
            grouped.putIfAbsent(block['userId'], () => []).add(block);
          }

          // 모든 uid(차단된 유저 + 차단 요청자)
          final uids = <String>{
            ...grouped.keys,
            ...allBlocks.map((e) => e['blockedBy'] as String),
          };

          return FutureBuilder<Map<String, Map<String, String>>>(
            future: fetchProfiles(uids),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profileMap = profileSnapshot.data ?? {};

              return ListView(
                children: grouped.entries.map((entry) {
                  final userId = entry.key;
                  final blocks = entry.value;
                  final profile = profileMap[userId] ?? {};
                  final nickname = profile['nickname'] ?? userId;
                  final thumbUrl = profile['thumbUrl'] ?? '';
                  final requesterCount = blocks.map((e) => e['blockedBy']).toSet().length;

                  bool expanded = false;

                  return StatefulBuilder(
                    builder: (context, setInnerState) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 상단: 차단 대상 정보
                              Row(
                                children: [
                                  thumbUrl.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 22,
                                          backgroundImage: AssetImage(thumbUrl),
                                          backgroundColor: Colors.transparent,
                                        )
                                      : const CircleAvatar(
                                          radius: 22,
                                          child: Icon(Icons.person, size: 22),
                                          backgroundColor: Colors.transparent,
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nickname,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "차단 요청자: $requesterCount명",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      expanded ? Icons.expand_less : Icons.expand_more,
                                    ),
                                    onPressed: () => setInnerState(() {
                                      expanded = !expanded;
                                    }),
                                  ),
                                ],
                              ),

                              // ▼ 사유 펼침
                              if (expanded)
                                Column(
                                  children: blocks.map((report) {
                                    final formattedDate =
                                        formatDate(report['createdAt'] as DateTime?);
                                    final blocker = profileMap[report['blockedBy']] ?? {};
                                    final blockerNick =
                                        blocker['nickname'] ?? report['blockedBy'];
                                    final blockerThumb = blocker['thumbUrl'] ?? '';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey, width: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // 차단자 썸네일
                                          blockerThumb.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage: AssetImage(blockerThumb),
                                                  backgroundColor: Colors.transparent,
                                                )
                                              : const CircleAvatar(
                                                  radius: 14,
                                                  child: Icon(Icons.person, size: 14),
                                                ),
                                          const SizedBox(width: 8),

                                          // 사유 및 닉네임
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  blockerNick,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '사유: ${report['reason'] ?? ''}',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
