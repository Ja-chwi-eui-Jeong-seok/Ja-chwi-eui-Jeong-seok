import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/domain/entities/comment.dart';

import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/presentation/providers/comment_like_providers.dart'; //as cl;
import 'package:ja_chwi/presentation/providers/comment_usecase_provider.dart';
import 'package:ja_chwi/presentation/providers/community_usecase_provider.dart';

/// 상세 화면 상태
class CommunityDetailState {
  final Community? post;
  final bool loadingPost;

  final List<Comment> comments;
  final bool loadingComments;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
  final CommentOrder order;

  //현재 로그인 사용자가 좋아요를 누른 commentId 집합
  final Set<String> likedIds;
  //게시글작성 후 돌아오는게시글id

  const CommunityDetailState({
    this.post,
    this.loadingPost = false,
    this.comments = const [],
    this.loadingComments = false,
    this.hasMore = true,
    this.lastDoc,
    this.order = CommentOrder.latest,
    this.likedIds = const {},
  });

  CommunityDetailState copyWith({
    Community? post,
    bool? loadingPost,
    List<Comment>? comments,
    bool? loadingComments,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
    CommentOrder? order,
    Set<String>? likedIds,
  }) => CommunityDetailState(
    post: post ?? this.post,
    loadingPost: loadingPost ?? this.loadingPost,
    comments: comments ?? this.comments,
    loadingComments: loadingComments ?? this.loadingComments,
    hasMore: hasMore ?? this.hasMore,
    lastDoc: lastDoc ?? this.lastDoc,
    order: order ?? this.order,
    likedIds: likedIds ?? this.likedIds,
  );
}

/// 상세 VM
class CommunityDetailVM extends Notifier<CommunityDetailState> {
  CommunityDetailVM(this.communityId);
  final String communityId;

  @override
  CommunityDetailState build() => const CommunityDetailState();

  /// 초기 로드: 게시글 + 댓글 + 좋아요집합
  Future<void> loadInitial(WidgetRef ref) async {
    // 게시글과 댓글은 병렬로 가져오되,
    // 좋아요 집합은 "댓글이 로드된 후" 호출해야 한다.
    await Future.wait([
      _loadPost(ref),
      _loadComments(ref, reset: true),
    ]);
    await _loadLikedSet(ref);
  }

  /// 단건 게시글 조회
  Future<void> _loadPost(WidgetRef ref) async {
    state = state.copyWith(loadingPost: true);
    try {
      final post = await ref.read(getCommunityByIdProvider).call(communityId);
      state = state.copyWith(post: post);
    } catch (e) {
      debugPrint('getById error: $e');
    } finally {
      state = state.copyWith(loadingPost: false);
    }
  }

  // 댓글 페이지 로드
  Future<void> _loadComments(WidgetRef ref, {bool reset = false}) async {
    if (state.loadingComments) return;
    if (!reset && !state.hasMore) return;

    state = state.copyWith(loadingComments: true);
    try {
      final page = await ref
          .read(fetchCommentsProvider)
          .call(
            communityId: communityId,
            order: state.order,
            limit: 20,
            startAfter: reset ? null : state.lastDoc,
          );

      state = state.copyWith(
        comments: reset ? page.items : [...state.comments, ...page.items],
        lastDoc: page.lastDoc,
        hasMore: page.hasMore && page.items.isNotEmpty,
      );
    } catch (e) {
      debugPrint('fetch comments error: $e');
    } finally {
      state = state.copyWith(loadingComments: false);
    }
  }

  // 현재 로드된 댓글 목록 기준, 로그인 사용자가 좋아요한 commentId 집합 로드
  Future<void> _loadLikedSet(WidgetRef ref) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || state.comments.isEmpty) {
      state = state.copyWith(likedIds: {});
      return;
    }

    final ids = state.comments.map((c) => c.id).toList();
    try {
      final liked = await ref
          .read(fetchUserLikedCommentIdsProvider)
          .call(uid: uid, commentIds: ids);
      state = state.copyWith(likedIds: liked);
    } catch (e) {
      debugPrint('fetch liked set error: $e');
      state = state.copyWith(likedIds: {});
    }
  }

  //댓글 생성 (서버시간 반영된 결과를 즉시 받도록 UC에서 처리)
  Future<void> createComment(
    WidgetRef ref, {
    required String uid,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;

    final created = await ref
        .read(createCommentProvider)
        .call(
          communityId: communityId, // 현재 상세 화면의 게시글 doc.id
          uid: uid,
          noteDetail: t,
        );

    //최신순이면 상단 prepend. 인기순이면 재쿼리.
    if (state.order == CommentOrder.latest) {
      state = state.copyWith(comments: [created, ...state.comments]);
      // 새 댓글은 기본적으로 liked=false. likedIds 변경 없음.
    } else {
      await refreshComments(ref, state.order);
    }
  }

  //정렬 전환 또는 강제 새로고침
  Future<void> refreshComments(WidgetRef ref, CommentOrder order) async {
    state = state.copyWith(order: order, lastDoc: null, hasMore: true);
    await _loadComments(ref, reset: true);
    await _loadLikedSet(ref); // 정렬 기준이 바뀌었으니 좋아요 집합도 갱신
  }

  //무한 스크롤 추가 로드
  Future<void> loadMore(WidgetRef ref) async {
    final beforeCount = state.comments.length;
    await _loadComments(ref, reset: false);
    // 새 댓글이 붙었다면 그 부분에 대한 좋아요 집합도 갱신
    if (state.comments.length > beforeCount) {
      await _loadLikedSet(ref);
    }
  }

  //좋아요 토글(중복 방지 + 카운트 동기)
  Future<void> toggleLike(WidgetRef ref, String commentId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      //로그인 가드. UI에서 토스트 안내 권장.
      return;
    }

    //서버 토글 (원자적 보장)
    final toggledToLiked = await ref
        .read(toggleCommentLikeProvider)
        .call(commentId: commentId, uid: uid);

    // 1) 로컬 likedIds 갱신
    final next = Set<String>.from(state.likedIds);
    if (toggledToLiked) {
      next.add(commentId);
    } else {
      next.remove(commentId);
    }

    // 2) 로컬 목록의 likeCount 동기 갱신
    final updated = state.comments.map((c) {
      if (c.id != commentId) return c;
      final delta = toggledToLiked ? 1 : -1;
      final nextCount = (c.likeCount + delta).clamp(0, 1 << 31);
      return c.copyWith(likeCount: nextCount);
    }).toList();

    state = state.copyWith(likedIds: next, comments: updated);
  }
}

/// Provider factory (communityId별 인스턴스)
NotifierProvider<CommunityDetailVM, CommunityDetailState>
communityDetailVmProvider(String communityId) {
  return NotifierProvider<CommunityDetailVM, CommunityDetailState>(
    () => CommunityDetailVM(communityId),
  );
}
