// --- 댓글 리스트 ---
// 기존 CommentCard의 주석과 형태를 유지하되, VM 데이터로 교체

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/RelativeTimeTextKst.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/heart_button.dart';

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

        return GestureDetector(
          onLongPressStart: (details) async {
            //details = onLongPressStart했을떄 정보
            final scaffold = ScaffoldMessenger.of(context);
            //현재화면의 최상단 레이어(Overlay)를 찾고 그 랜더박스 정보 제공, 목적: 화면전체 크기를 얻어 메뉴 위치계산에 사용
            final overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;

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
              ],
            );

            //selected의 value에 따라 기능실행
            switch (selected) {
              case 'report':
                // 신고 처리
                scaffold.showSnackBar(const SnackBar(content: Text('신고 완료')));
                break;
              case 'block':
                // 차단 처리
                scaffold.showSnackBar(const SnackBar(content: Text('차단 완료')));
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
                  child: Builder(
                    builder: (_) {
                      final uid = uidOf(i);
                      final av = ref.watch(profileByUidProvider(uid));
                      return av.when(
                        data: (p) => ClipRRect(
                          borderRadius: BorderRadius.circular(22.5),
                          child: (p.thumbUrl.isNotEmpty
                              ? Image.asset(p.thumbUrl)
                              : (p.imageFullUrl.isNotEmpty
                                    ? Image.asset(p.imageFullUrl)
                                    : Image.asset(
                                        'assets/images/m_profile/m_black.png',
                                      ))),
                        ),
                        loading: () => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(radius: 22.5),
                        ),
                        error: (_, __) => const CircleAvatar(
                          radius: 22.5,
                          child: Icon(Icons.person),
                        ),
                      );
                    },
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
                          Builder(
                            builder: (_) {
                              final uid = uidOf(i);
                              final av = ref.watch(profileByUidProvider(uid));
                              final nickname = av.maybeWhen(
                                data: (p) => p.nickname,
                                orElse: () => uid, // 로딩/에러 시 임시로 uid
                              );
                              return Text(
                                nickname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),

                          RelativeTimeTextKst(
                            createdAtUtc: createdAtOf(i).toUtc(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        //댓글내용
                        textOf(i),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                HeartButton(
                  liked: isLikedOf(i),
                  count: likeCountOf(i),
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
