import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/bookmark_entity.dart';

class BookmarkDataSource {
  final FirebaseFirestore _firestore;

  BookmarkDataSource(this._firestore);

  Future<void> addBookmark(String uid, BookmarkEntity bookmark) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc('${bookmark.type}_${bookmark.id}')
        .set({
      'id': bookmark.id,
      'type': bookmark.type.toString(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String uid, String id, BookmarkType type) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc('${type}_$id')
        .delete();
  }

  Stream<List<BookmarkEntity>> getBookmarks(String uid, [BookmarkType? type]) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final id = data['id'] as String?;
        final typeStr = data['type'] as String?;
        final timestamp = data['createdAt'] as Timestamp?;

        if (id == null || typeStr == null || timestamp == null) {
          return null; // 잘못된 데이터는 무시
        }

        // 타입 변환 안전하게
        final typeEnum = BookmarkType.values.firstWhere(
          (e) => e.toString() == typeStr,
          orElse: () => BookmarkType.community,
        );

        return BookmarkEntity(
          id: id,
          type: typeEnum,
          createdAt: timestamp.toDate(),
        );
      }).whereType<BookmarkEntity>().toList(); // null 제거
    });
  }
}
