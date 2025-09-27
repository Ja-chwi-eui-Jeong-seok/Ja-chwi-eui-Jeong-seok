import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ja_chwi/data/datasources/comment_like_data_source.dart';
import 'package:ja_chwi/data/datasources/comment_like_data_source_impl.dart';
import 'package:ja_chwi/domain/repositories/comment_like_repository.dart';
import 'package:ja_chwi/data/repositories/comment_like_repository_impl.dart';
import 'package:ja_chwi/domain/usecases/toggle_comment_like.dart';
import 'package:ja_chwi/domain/usecases/fetch_user_liked_comment_ids.dart';

/// DS
final commentLikeDsProvider = Provider<CommentLikeDataSource>(
  (ref) => CommentLikeDataSourceImpl(FirebaseFirestore.instance),
);

/// Repo
final commentLikeRepoProvider = Provider<CommentLikeRepository>(
  (ref) => CommentLikeRepositoryImpl(ref.read(commentLikeDsProvider)),
);

/// 좋아요 토글 (true=좋아요됨, false=해제)
final toggleCommentLikeProvider = Provider<ToggleCommentLike>(
  (ref) => ToggleCommentLike(ref.read(commentLikeRepoProvider)),
);

/// 사용자가 주어진 댓글들 중 좋아요한 commentId 집합 조회
final fetchUserLikedCommentIdsProvider = Provider<FetchUserLikedCommentIds>(
  (ref) => FetchUserLikedCommentIds(ref.read(commentLikeRepoProvider)),
);
