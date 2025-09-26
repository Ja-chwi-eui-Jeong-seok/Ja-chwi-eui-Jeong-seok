import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/data/datasources/comment_data_source_impl.dart';
import 'package:ja_chwi/data/repositories/comment_repository_impl.dart';
import 'package:ja_chwi/domain/repositories/comment_repository.dart';
import 'package:ja_chwi/domain/usecases/create_comment.dart';
import 'package:ja_chwi/domain/usecases/fetch_comments.dart';

final commentDsProvider = Provider<CommentDataSource>(
  (ref) => CommentDataSourceImpl(FirebaseFirestore.instance),
);

final commentRepoProvider = Provider<CommentRepository>(
  (ref) => CommentRepositoryImpl(ref.read(commentDsProvider)),
);

final createCommentProvider = Provider(
  (ref) => CreateComment(ref.read(commentRepoProvider)), // ✅ Comment 반환
);

final fetchCommentsProvider = Provider(
  (ref) => FetchComments(ref.read(commentRepoProvider)),
);
