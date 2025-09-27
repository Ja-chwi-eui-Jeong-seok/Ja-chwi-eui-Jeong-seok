// lib/presentation/screens/community/vm/community_detail_vm.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/presentation/providers/comment_usecase_provider.dart';
import 'package:ja_chwi/presentation/providers/community_usecase_provider.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';

class CommunityDetailState {
  final Community? post;
  final bool loadingPost;

  final List<Comment> comments;
  final bool loadingComments;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
  final CommentOrder order;

  const CommunityDetailState({
    this.post,
    this.loadingPost = false,
    this.comments = const [],
    this.loadingComments = false,
    this.hasMore = true,
    this.lastDoc,
    this.order = CommentOrder.latest,
  });

  CommunityDetailState copyWith({
    Community? post,
    bool? loadingPost,
    List<Comment>? comments,
    bool? loadingComments,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
    CommentOrder? order,
  }) => CommunityDetailState(
    post: post ?? this.post,
    loadingPost: loadingPost ?? this.loadingPost,
    comments: comments ?? this.comments,
    loadingComments: loadingComments ?? this.loadingComments,
    hasMore: hasMore ?? this.hasMore,
    lastDoc: lastDoc ?? this.lastDoc,
    order: order ?? this.order,
  );
}

class CommunityDetailVM extends Notifier<CommunityDetailState> {
  CommunityDetailVM(this.communityId);
  final String communityId;

  @override
  CommunityDetailState build() => const CommunityDetailState();

  Future<void> loadInitial(WidgetRef ref) async {
    await Future.wait([
      _loadPost(ref),
      _loadComments(ref, reset: true),
    ]);
  }

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

  Future<void> createComment(
    WidgetRef ref, {
    required String uid,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;

    // 서버시간 반영된 댓글을 생성해서 즉시 받기
    final created = await ref
        .read(createCommentProvider)
        .call(
          communityId: communityId, // 현재 상세 화면의 게시글 doc.id
          uid: uid,
          noteDetail: t,
        );

    // 정렬 상태에 맞게 UI 반영
    if (state.order == CommentOrder.latest) {
      state = state.copyWith(comments: [created, ...state.comments]);
    } else {
      await refreshComments(ref, state.order);
    }
  }

  Future<void> refreshComments(WidgetRef ref, CommentOrder order) async {
    state = state.copyWith(order: order, lastDoc: null, hasMore: true);
    await _loadComments(ref, reset: true);
  }

  Future<void> loadMore(WidgetRef ref) => _loadComments(ref, reset: false);
}

NotifierProvider<CommunityDetailVM, CommunityDetailState>
communityDetailVmProvider(String communityId) {
  return NotifierProvider<CommunityDetailVM, CommunityDetailState>(
    () => CommunityDetailVM(communityId),
  );
}
