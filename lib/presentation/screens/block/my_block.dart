import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBlocksPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const MyBlocksPage({super.key, this.extra});

  @override
  State<MyBlocksPage> createState() => _MyBlocksPageState();
}

class _MyBlocksPageState extends State<MyBlocksPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _myBlocks;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("MyBlocksPage extra: ${widget.extra}");
    }
    final myUid = widget.extra?['uid'] as String?;
    _myBlocks = myUid != null ? fetchMyBlocks(myUid) : Future.value([]);
  }

  /// 내가 차단한 목록 조회
  Future<List<Map<String, dynamic>>> fetchMyBlocks(String myUid) async {
    final snapshot = await firestore
        .collection('blocks')
        .where('blockedBy', isEqualTo: myUid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'userId': data['userId'] ?? '',
        'reason': data['reason'] ?? '',
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      };
    }).toList();
  }

  /// uid → {nickname, thumbUrl} 매핑
  Future<Map<String, Map<String, String>>> fetchProfiles(
    Set<String> uids,
  ) async {
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

  /// 차단 해제 함수
  Future<void> unblockUser(String blockId) async {
    try {
      await firestore.collection('blocks').doc(blockId).delete();
      setState(() {
        _myBlocks = fetchMyBlocks(widget.extra?['uid']);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차단이 해제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('차단 해제 실패: $e')),
      );
    }
  }

  /// 날짜 포맷
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 차단한 내역"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/settings', extra: widget.extra),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _myBlocks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          }

          final blocks = snapshot.data;
          if (blocks == null || blocks.isEmpty) {
            return const Center(
              child: Text(
                "차단한 내역이 없습니다.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final uids = blocks.map((b) => b['userId'] as String).toSet();

          return FutureBuilder<Map<String, Map<String, String>>>(
            future: fetchProfiles(uids),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (profileSnapshot.hasError) {
                return Center(
                  child: Text("프로필 로딩 오류: ${profileSnapshot.error}"),
                );
              }

              final profileMap = profileSnapshot.data ?? {};

              return ListView.builder(
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  final block = blocks[index];
                  final blockedUid = block['userId'] as String;
                  final profile = profileMap[blockedUid] ?? {};
                  final nickname = profile['nickname'] ?? blockedUid;
                  final thumbUrl = profile['thumbUrl'] ?? '';
                  final reason = block['reason'];
                  final createdAt = block['createdAt'] as DateTime?;

                  return Card(
                    color: Colors.white, // 배경색
                    elevation: 0, // 그림자 깊이 (0이면 그림자 없음)
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 썸네일
                          thumbUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(thumbUrl),
                                  backgroundColor: const Color.fromARGB(
                                    0,
                                    29,
                                    13,
                                    13,
                                  ), // 배경 투명
                                )
                              : const CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.person, size: 20),
                                ),
                          const SizedBox(width: 12),

                          // 닉네임 + 사유/차단일
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nickname,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (reason.isNotEmpty || createdAt != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (reason.isNotEmpty)
                                        Text(
                                          "사유: $reason",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      if (createdAt != null)
                                        Text(
                                          "차단일: ${formatDate(createdAt)}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 차단 해제 버튼
                          OutlinedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    "$nickname 님의 차단을 해제하시겠습니까?",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Text(
                                    "차단 해제 시, $nickname 님의 모든 활동이 다시 보이게 됩니다.",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actionsPadding: const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                        foregroundColor: Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text("취소"),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.redAccent,
                                        ),
                                        foregroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text("해제"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await unblockUser(block['id']);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: const Size(60, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "차단 해제",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
