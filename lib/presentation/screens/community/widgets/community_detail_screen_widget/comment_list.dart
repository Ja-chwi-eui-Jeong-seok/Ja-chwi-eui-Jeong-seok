import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/providers/block_provider.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/app_confirm_dialog.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/RelativeTimeTextKst.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/heart_button.dart';

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
  });

  final int itemCount;
  final String Function(int) uidOf;
  final String Function(int) textOf;
  final int Function(int) likeCountOf;
  final bool loading;
  final bool Function(int) isLikedOf;
  final void Function(int) onToggleLike;
  final DateTime Function(int) createdAtOf;

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
    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      itemCount: itemCount + (loading ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        if (i >= itemCount) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final me = FirebaseAuth.instance.currentUser?.uid;
        final targetUid = uidOf(i); // 이 댓글 작성자 uid

        late final nickname;
        late final thumbUrl;

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

        return GestureDetector(
          onLongPressStart: isBlocked
              ? null
              : (details) async {
                  //details = onLongPressStart했을떄 정보
                  final scaffold = ScaffoldMessenger.of(context);
                  //현재화면의 최상단 레이어(Overlay)를 찾고 그 랜더박스 정보 제공, 목적: 화면전체 크기를 얻어 메뉴 위치계산에 사용
                  final overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;

                  //showMenu : 팝업 메뉴 표시
                  final selected = await showMenu<String>(
                    //꾹 눌렀을때 나오는 메뉴 모양 커스텀
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(15),
                    ),
                    context: context,

                    //작은사각형이 큰 사각형의 어디있는지 상대좌표로 변환하여 메뉴 시작위치가 터치 지점으로 잡힘
                    position: RelativeRect.fromRect(
                      //사용자가 누른 지점을 0,0사이즈의 사각형으로 표현
                      Rect.fromLTWH(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        0,
                        0,
                      ),

                      //화면 전체를 덮는 사각형
                      Offset.zero & overlay.size,
                    ),
                    color: Colors.white,
                    items: [
                      if (me != targetUid) ...[
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: const [
                              Text('신고하기'),
                              SizedBox(width: 50),
                              Spacer(),
                              Icon(Icons.notifications_none),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: const [
                              Text('차단하기'),
                              Spacer(),
                              Icon(Icons.do_not_disturb_on_outlined),
                            ],
                          ),
                        ),
                      ] else ...[
                        // 내 댓글용 메뉴
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Text('삭제하기'),
                              Spacer(),
                              Icon(Icons.delete_outline),
                            ],
                          ),
                        ),
                        //TODO: 삭제하기
                      ],
                    ],
                  );

                  //selected의 value에 따라 기능실행
                  switch (selected) {
                    case 'report':
                      // 신고 처리
                      if (me == null) {
                        scaffold.showSnackBar(
                          const SnackBar(content: Text('로그인이 필요합니다.')),
                        );
                        break;
                      }

                      // 신고하기 페이지로 이동
                      context.push(
                        '/report',
                        extra: {
                          'targetUserId': targetUid,
                          'targetUserName': nickname,
                          'targetContent': textOf(i),
                          'targetCreatedAt': createdAtOf(i),
                        },
                      );
                      break;
                    case 'block':
                      // 차단 처리
                      if (me == null) {
                        scaffold.showSnackBar(
                          const SnackBar(content: Text('로그인이 필요합니다.')),
                        );
                        break;
                      }

                      final ok = await showAppConfirmDialog(
                        context,
                        title: '$nickname 님을 차단할까요',
                        message: '차단하면 이 사용자의 게시글과 댓글이 보이지 않음',
                        primaryText: '확인',
                        secondaryText: '취소',
                        destructive: true,
                      );

                      if (ok == true) {
                        final err = await ref.read(blockUserActionProvider)(
                          myUid: me,
                          targetUid: uidOf(i), // 해당 댓글 작성자 uid
                          reason: null,
                        );
                        if (err != null) {
                          scaffold.showSnackBar(SnackBar(content: Text(err)));
                        } else {
                          scaffold.showSnackBar(
                            const SnackBar(content: Text('차단 완료')),
                          );
                          // 목록 즉시 반영
                          ref
                              .read(communityChangedTickProvider.notifier)
                              .state++;
                          // 차단된 유저 목록 새로고침
                          ref.invalidate(blockedUsersProvider);
                        }
                      }

                      break;
                    case 'delete':
                      //TODO: 삭제 처리
                      scaffold.showSnackBar(
                        const SnackBar(content: Text('삭제 완료')),
                      );
                      ref.read(communityChangedTickProvider.notifier).state++;
                      break;
                    case null:
                      // 메뉴 밖을 눌러 닫힘. 아무것도 하지 않음.
                      break;
                  }
                },
          child: Container(
            color: Colors.white,
            // height: 80,
            child: Row(
              children: [
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          //작성자이름
                          Text(
                            nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isBlocked ? Colors.grey : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(
                            width: 8,
                          ),

                          RelativeTimeTextKst(
                            createdAtUtc: createdAtOf(i).toUtc(),
                            style: TextStyle(
                              fontSize: 12,
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
                                      if (blockedUsers.contains(targetUid)) {
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
                                  overflow: TextOverflow.ellipsis,
                                  style: blockedUsersAsync.when(
                                    data: (blockedUsers) {
                                      if (blockedUsers.contains(targetUid)) {
                                        final isVisible = ref.watch(
                                          blockedCommentVisibilityProvider(
                                            uidOf(i),
                                          ),
                                        );
                                        return TextStyle(
                                          color: isVisible ? null : Colors.grey,
                                          fontStyle: isVisible
                                              ? null
                                              : FontStyle.italic,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
