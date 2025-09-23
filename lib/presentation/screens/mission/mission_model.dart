import 'package:cloud_firestore/cloud_firestore.dart';

class Mission {
  final int missioncode;
  final String missiontitle;
  final List<String> tags;

  Mission({
    required this.missioncode,
    required this.missiontitle,
    required this.tags,
  });

  // Firestore 문서(QueryDocumentSnapshot)로부터 Mission 객체를 생성하는 팩토리 생성자
  factory Mission.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Mission(
      missioncode: data['missioncode'] as int? ?? 0,
      missiontitle: data['missiontitle'] as String? ?? '미션 없음',
      tags: List<String>.from(data['tags'] as List? ?? []),
    );
  }
}
