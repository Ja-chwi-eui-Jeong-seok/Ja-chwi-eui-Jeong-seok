import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/presentation/providers/block_provider.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/relativeTimeTextKst.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/heart_button.dart';
import 'package:ja_chwi/presentation/providers/reply_mode_provider.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/comment_long_press_actions.dart';

// 차단된 댓글의 표시 상태를 관리하는 provider
final blockedCommentVisibilityProvider = StateProvider.family<bool, String>(
  (ref, commentId) => false,
);

class CommentList extends ConsumerWidget {
  const CommentList({
    super.key,
    required this.itemCount,
    required this.uidOf,
    required this.textOf,
    required this.likeCountOf,
    required this.loading,
    required this.isLikedOf,
    required this.onToggleLike,
    required this.createdAtOf,
    required this.comments,
    required this.detailVmProvider,
    this.commentFocusNode,
  });

  final int itemCount;
  final String Function(int) uidOf;
  final String Function(int) textOf;
  final int Function(int) likeCountOf;
  final bool loading;
  final bool Function(int) isLikedOf;
  final void Function(int) onToggleLike;
  final DateTime Function(int) createdAtOf;
  final List<Comment> comments;
  final NotifierProvider<CommunityDetailVM, CommunityDetailState>
  detailVmProvider;
  final FocusNode? commentFocusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 차단된 유저 목록 가져오기
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

    //댓글카운트
    if (itemCount == 0) {
      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: Text(
            '댓글이 아직 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // shrinkWrap/physics 건드리지 않기
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: itemCount + (loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= itemCount) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final me = FirebaseAuth.instance.currentUser?.uid;
        final targetUid = uidOf(i); // 이 댓글 작성자 uid

        late final String nickname;
        late final String thumbUrl;

        // 차단된 유저인지 확인
        final isBlocked = blockedUsersAsync.when(
          data: (blockedUsers) => blockedUsers.contains(targetUid),
          loading: () => false,
          error: (_, __) => false,
        );

        if (isBlocked) {
          // 차단된 유저인 경우 기본값으로 설정
          nickname = '차단된 사용자';

          thumbUrl = 'assets/images/m_profile/m_black.png';
        } else {
          // 차단되지 않은 유저인 경우 기존 로직 사용
          ref
              .read(profileByUidProvider(targetUid))
              .maybeWhen(
                data: (p) {
                  nickname = p.nickname;

                  thumbUrl = p.thumbUrl;
                },
                loading: () {
                  nickname = '불러오는중';

                  thumbUrl = 'assets/images/m_profile/m_black.png';
                },
                orElse: () {
                  nickname = '사용자';

                  thumbUrl = 'assets/images/m_profile/m_black.png';
                },
                error: (error, stackTrace) {
                  nickname = '사용자';

                  thumbUrl = 'assets/images/m_profile/m_black.png';
                },
              );
        }

        return Column(
          children: [
            GestureDetector(
              onLongPressStart: isBlocked
                  ? null
                  : (details) async {
                      await showCommentContextMenu(
                        context: context,
                        ref: ref,
                        details: details,
                        meUid: me,
                        targetUid: targetUid,
                        nickname: nickname,
                        commentText: textOf(i),
                        createdAt: createdAtOf(i),
                        detailVmProvider: detailVmProvider,
                        comments: comments,
                        index: i,
                      );
                    },
              child: Column(
                children: [
                  // 메인 댓글
                  Consumer(
                    builder: (context, ref, child) {
                      final replyMode = ref.watch(replyModeProvider);
                      final replyData = ref.watch(replyModeDataProvider);

                      // 답글 모드이고 현재 댓글이 답글 대상인 경우 회색 배경
                      final backgroundColor =
                          (replyMode == ReplyMode.replying &&
                              replyData != null &&
                              replyData.parentCommentId == comments[i].id)
                          ? Colors.grey[100]
                          : Colors.white;

                      return Container(
                        color: backgroundColor,

                        child: Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                //좌우 패딩용
                                SizedBox(
                                  width: 25,
                                ),
                                SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22.5),
                                    child: ColorFiltered(
                                      colorFilter: isBlocked
                                          ? const ColorFilter.mode(
                                              Colors.grey,
                                              BlendMode.saturation,
                                            )
                                          : const ColorFilter.mode(
                                              Colors.transparent,
                                              BlendMode.multiply,
                                            ),
                                      child: Image.asset(thumbUrl),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          //작성자이름
                                          Text(
                                            nickname,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: isBlocked
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          SizedBox(
                                            width: 8,
                                          ),
                                          //댓글작성날짜
                                          RelativeTimeTextKst(
                                            createdAtUtc: createdAtOf(
                                              i,
                                            ).toUtc(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isBlocked
                                                  ? Colors.grey.shade400
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: isBlocked
                                                  ? () {
                                                      // 차단된 댓글을 클릭하면 표시 상태 토글
                                                      final currentVisibility = ref
                                                          .read(
                                                            blockedCommentVisibilityProvider(
                                                              uidOf(i),
                                                            ).notifier,
                                                          )
                                                          .state;
                                                      ref
                                                              .read(
                                                                blockedCommentVisibilityProvider(
                                                                  uidOf(i),
                                                                ).notifier,
                                                              )
                                                              .state =
                                                          !currentVisibility;
                                                    }
                                                  : null,
                                              child: MouseRegion(
                                                cursor: isBlocked
                                                    ? SystemMouseCursors.click
                                                    : SystemMouseCursors.basic,
                                                child: Text(
                                                  //댓글내용 - 차단된 유저인지 확인
                                                  blockedUsersAsync.when(
                                                    data: (blockedUsers) {
                                                      if (blockedUsers.contains(
                                                        targetUid,
                                                      )) {
                                                        // 차단된 유저인 경우, 표시 상태에 따라 내용 결정
                                                        final isVisible = ref.watch(
                                                          blockedCommentVisibilityProvider(
                                                            uidOf(i),
                                                          ),
                                                        );
                                                        return isVisible
                                                            ? textOf(i)
                                                            : '(차단된 유저입니다)';
                                                      }
                                                      return textOf(i);
                                                    },
                                                    loading: () => textOf(i),
                                                    error: (_, __) => textOf(i),
                                                  ),
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: blockedUsersAsync.when(
                                                    data: (blockedUsers) {
                                                      if (blockedUsers.contains(
                                                        targetUid,
                                                      )) {
                                                        final isVisible = ref.watch(
                                                          blockedCommentVisibilityProvider(
                                                            uidOf(i),
                                                          ),
                                                        );
                                                        return TextStyle(
                                                          color: isVisible
                                                              ? null
                                                              : Colors.grey,
                                                          fontStyle: isVisible
                                                              ? null
                                                              : FontStyle
                                                                    .italic,
                                                          fontSize: 12,
                                                        );
                                                      }
                                                      return null;
                                                    },
                                                    loading: () => null,
                                                    error: (_, __) => null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isBlocked) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.visibility_outlined,
                                              size: 16,
                                              color: Colors.grey.shade500,
                                            ),
                                          ],
                                        ],
                                      ),

                                      // 답글달기 버튼
                                      if (!isBlocked) ...[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton(
                                            onPressed: () => _toggleReplyInput(
                                              ref,
                                              comments[i],
                                            ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              '답글달기',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (isBlocked)
                                  ...[]
                                else
                                  HeartButton(
                                    liked: isBlocked ? false : isLikedOf(i),
                                    count: isBlocked ? 0 : likeCountOf(i),
                                    onPressed: () => onToggleLike(i),
                                  ),
                                SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 답글 목록 (댓글 box 바깥에 표시)
                  if (comments[i].replies.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(
                        left: 80,
                      ),
                      child: Column(
                        children: comments[i].replies.map((reply) {
                          // 체크: 답글 작성자가 차단된 유저인지
                          final isReplyBlocked = blockedUsersAsync.when(
                            data: (blockedUsers) =>
                                blockedUsers.contains(reply.uid),
                            loading: () => false,
                            error: (_, __) => false,
                          );

                          return GestureDetector(
                            onLongPressStart: isReplyBlocked
                                ? null
                                : (details) async {
                                    final me =
                                        FirebaseAuth.instance.currentUser?.uid;
                                    await showCommentContextMenu(
                                      context: context,
                                      ref: ref,
                                      details: details,
                                      meUid: me,
                                      targetUid: reply.uid,
                                      nickname: reply.uid,
                                      commentText: reply.noteDetail,
                                      createdAt: reply.createAt,
                                      onDelete: (me != null && me == reply.uid)
                                          ? () async {
                                              await ref
                                                  .read(
                                                    detailVmProvider.notifier,
                                                  )
                                                  .deleteReply(
                                                    ref,
                                                    parentCommentId:
                                                        comments[i].id,
                                                    replyId: reply.id,
                                                  );
                                            }
                                          : null,
                                    );
                                  },
                            child: Container(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      // 답글 작성자 프로필 이미지 (댓글과 동일한 크기)
                                      SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            22.5,
                                          ),
                                          child: isReplyBlocked
                                              ? Image.asset(
                                                  'assets/images/m_profile/m_black.png',
                                                )
                                              : Consumer(
                                                  builder: (context, ref, child) {
                                                    final profileAsync = ref
                                                        .watch(
                                                          profileByUidProvider(
                                                            reply.uid,
                                                          ),
                                                        );

                                                    return profileAsync.when(
                                                      data: (profile) {
                                                        final thumbUrl =
                                                            profile.thumbUrl;
                                                        if (thumbUrl.isEmpty) {
                                                          return Image.asset(
                                                            'assets/images/m_profile/m_black.png',
                                                          );
                                                        }
                                                        if (thumbUrl.startsWith(
                                                          'http',
                                                        )) {
                                                          return Image.network(
                                                            thumbUrl,
                                                          );
                                                        }
                                                        return Image.asset(
                                                          thumbUrl,
                                                        );
                                                      },
                                                      loading: () => Image.asset(
                                                        'assets/images/m_profile/m_black.png',
                                                      ),
                                                      error: (_, __) => Image.asset(
                                                        'assets/images/m_profile/m_black.png',
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // 답글 내용 (차단된 경우 토글 가능)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // 닉네임 (차단된 경우 대체 텍스트)
                                                isReplyBlocked
                                                    ? Text(
                                                        '차단된 사용자',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.grey,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    : Consumer(
                                                        builder: (context, ref, child) {
                                                          final profileAsync =
                                                              ref.watch(
                                                                profileByUidProvider(
                                                                  reply.uid,
                                                                ),
                                                              );

                                                          return profileAsync.when(
                                                            data: (profile) => Text(
                                                              profile.nickname,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            loading: () => Text(
                                                              reply.uid,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            error: (_, __) => Text(
                                                              'error',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          );
                                                        },
                                                      ),

                                                const SizedBox(width: 8),

                                                // 시간 (댓글과 동일한 스타일)
                                                Text(
                                                  _formatTime(reply.createAt),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 4),

                                            // 답글 내용 (차단된 경우 표시 토글)
                                            isReplyBlocked
                                                ? GestureDetector(
                                                    onTap: () {
                                                      final currentVisibility = ref
                                                          .read(
                                                            blockedCommentVisibilityProvider(
                                                              reply.uid,
                                                            ).notifier,
                                                          )
                                                          .state;
                                                      ref
                                                              .read(
                                                                blockedCommentVisibilityProvider(
                                                                  reply.uid,
                                                                ).notifier,
                                                              )
                                                              .state =
                                                          !currentVisibility;
                                                    },
                                                    child: Builder(
                                                      builder: (context) {
                                                        final isVisible = ref.watch(
                                                          blockedCommentVisibilityProvider(
                                                            reply.uid,
                                                          ),
                                                        );
                                                        return Text(
                                                          isVisible
                                                              ? reply.noteDetail
                                                              : '(차단된 유저입니다)',
                                                          maxLines: 5,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isVisible
                                                                ? null
                                                                : Colors.grey,
                                                            fontStyle: isVisible
                                                                ? null
                                                                : FontStyle
                                                                      .italic,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Text(
                                                    reply.noteDetail,
                                                    maxLines: 5,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),

                                      // 차단 상태 아이콘
                                      if (isReplyBlocked) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleReplyInput(WidgetRef ref, Comment parentComment) {
    final replyMode = ref.read(replyModeProvider);
    final replyData = ref.read(replyModeDataProvider);

    // 이미 답글 모드이고 같은 댓글에 대한 답글인 경우 일반 모드로 복귀
    if (replyMode == ReplyMode.replying &&
        replyData != null &&
        replyData.parentCommentId == parentComment.id) {
      ref.read(replyModeProvider.notifier).state = ReplyMode.none;
      ref.read(replyModeDataProvider.notifier).state = null;
    } else {
      // 답글 모드로 전환
      ref
          .read(profileByUidProvider(parentComment.uid))
          .when(
            data: (profile) {
              ref.read(replyModeProvider.notifier).state = ReplyMode.replying;
              ref.read(replyModeDataProvider.notifier).state = ReplyModeData(
                parentCommentId: parentComment.id,
                parentCommentUid: parentComment.uid,
                parentCommentNickname: profile.nickname,
              );
            },
            loading: () {
              // 로딩 중이면 UID로 표시
              ref.read(replyModeProvider.notifier).state = ReplyMode.replying;
              ref.read(replyModeDataProvider.notifier).state = ReplyModeData(
                parentCommentId: parentComment.id,
                parentCommentUid: parentComment.uid,
                parentCommentNickname: parentComment.uid,
              );
            },
            error: (_, __) {
              // 에러 시 UID로 표시
              ref.read(replyModeProvider.notifier).state = ReplyMode.replying;
              ref.read(replyModeDataProvider.notifier).state = ReplyModeData(
                parentCommentId: parentComment.id,
                parentCommentUid: parentComment.uid,
                parentCommentNickname: parentComment.uid,
              );
            },
          );

      // 답글 모드로 전환 후 포커스
      if (commentFocusNode != null) {
        commentFocusNode!.requestFocus();
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
