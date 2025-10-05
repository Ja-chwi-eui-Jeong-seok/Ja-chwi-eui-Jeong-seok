import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/bookmark_datasource.dart';
import 'package:ja_chwi/data/repositories/bookmark_repository_impl.dart';
import 'package:ja_chwi/domain/entities/bookmark_entity.dart';
import 'package:ja_chwi/domain/repositories/bookmark_repository.dart';

// Repository provider
final bookmarkRepoProvider = Provider<BookmarkRepository>((ref) {
  final dataSource = BookmarkDataSource(FirebaseFirestore.instance);
  return BookmarkRepositoryImpl(dataSource);
});

// Stream provider for bookmarks
final bookmarksProvider = StreamProvider.family<List<BookmarkEntity>, Map<String, dynamic>>(
  (ref, args) {
    final uid = args['uid'] as String;
    final type = args['type'] as BookmarkType?;
    final repo = ref.watch(bookmarkRepoProvider);
    return repo.getBookmarks(uid, type);
  },
);
