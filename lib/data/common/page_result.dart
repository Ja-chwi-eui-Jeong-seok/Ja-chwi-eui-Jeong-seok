import 'package:cloud_firestore/cloud_firestore.dart';

class PagedResult<T> {
  final List<T> items; // 가져온 데이터들
  final DocumentSnapshot? lastDoc; // 다음 페이지를 위한 커서
  final bool hasMore; // 다음 페이지가 있을 수 있는지

  const PagedResult({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });
}
