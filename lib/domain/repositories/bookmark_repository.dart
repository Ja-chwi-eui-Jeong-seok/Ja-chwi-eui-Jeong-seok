import 'package:ja_chwi/domain/entities/bookmark_entity.dart';

abstract class BookmarkRepository {
  Future<void> addBookmark(String uid, BookmarkEntity bookmark);
  Future<void> removeBookmark(String uid, String id, BookmarkType type);
  Stream<List<BookmarkEntity>> getBookmarks(String uid, [BookmarkType? type]);
}
