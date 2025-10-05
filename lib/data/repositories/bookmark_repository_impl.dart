import 'package:ja_chwi/data/datasources/bookmark_datasource.dart';
import 'package:ja_chwi/domain/entities/bookmark_entity.dart';
import 'package:ja_chwi/domain/repositories/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkDataSource dataSource;

  BookmarkRepositoryImpl(this.dataSource);

  @override
  Future<void> addBookmark(String uid, BookmarkEntity bookmark) {
    return dataSource.addBookmark(uid, bookmark);
  }

  @override
  Future<void> removeBookmark(String uid, String id, BookmarkType type) {
    return dataSource.removeBookmark(uid, id, type);
  }

  @override
  Stream<List<BookmarkEntity>> getBookmarks(String uid, [BookmarkType? type]) {
    return dataSource.getBookmarks(uid, type);
  }
}
