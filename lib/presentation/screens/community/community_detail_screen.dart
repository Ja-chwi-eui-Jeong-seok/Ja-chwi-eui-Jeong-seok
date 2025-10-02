import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/comment_list.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/comment_write.dart';
import 'package:timezone/timezone.dart' as tz;

//타임존
final tz.Location _seoul = tz.getLocation('Asia/Seoul');

class CommunityDetailScreen extends ConsumerStatefulWidget {
  // 라우터에서 id를 extra로 넘김: context.push('/community-detail', extra: x.id)
  const CommunityDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final commentController = TextEditingController();

  // 상세 VM 프로바이더 인스턴스 보관
  late final provider = communityDetailVmProvider(widget.id);

  @override
  void initState() {
    super.initState();
    // 첫 진입 시 단건 게시글 + 댓글 초기 로드
    Future.microtask(
      () => ref.read(provider.notifier).loadInitial(ref),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  //댓글입력
  void submit() async {
    if (!mounted) return;
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    await ref
        .read(provider.notifier)
        .createComment(
          ref,
          uid: uid, //uid로 프로필조회 -> 닉네임, 프로필이미지
          text: text,
        );

    if (!mounted) return;
    commentController.clear();
  }

  Widget _pagedList(WidgetRef ref, CommunityDetailState st) {
    // 자식(ListView 등) 스크롤 이벤트를 이 콜백에서 받는다.
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // 위치가 변할 때마다 들어오는 업데이트 알림만 처리
        if (n is ScrollUpdateNotification) {
          //n.metrics.maxScrollExtent - n.metrics.pixels 바닥까지 남은 거리
          //pixels 현재위치
          //maxScrollExtent 스크롤 가능한 최대 위치
          final remain = n.metrics.maxScrollExtent - n.metrics.pixels;
          // 200px 이내로 접근했고, 현재 로딩 중이 아니며, 더 가져올 게 있으면 페이지 로드
          if (remain < 200 && !st.loadingComments && st.hasMore) {
            ref.read(provider.notifier).loadMore(ref);
          }
        }
        // 알림을 상위로 계속 올림 true면 중단
        return false;
      },
      child: CommentList(
        itemCount: st.comments.length,
        likeCountOf: (i) => st.comments[i].likeCount,
        uidOf: (i) => st.comments[i].uid,
        textOf: (i) => st.comments[i].noteDetail,
        loading: st.loadingComments,
        isLikedOf: (i) => st.likedIds.contains(st.comments[i].id),
        onToggleLike: (i) =>
            ref.read(provider.notifier).toggleLike(ref, st.comments[i].id),
        createdAtOf: (i) => st.comments[i].createAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(provider);
    //현재유저의 uid 정보
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // 화면 헤더 데이터 구성
    //게시글과 게시글 작성자 정보
    final title = st.post?.communityName ?? '제목';
    final authorUid = st.post?.createUser;
    final author = authorUid == null
        ? '작성자'
        : ref
              .watch(profileByUidProvider(authorUid))
              .maybeWhen(data: (p) => p.nickname, orElse: () => '작성자');
    final authorImg = authorUid == null
        ? 'assets/images/m_profile/m_black.png'
        : ref
              .watch(profileByUidProvider(authorUid))
              .maybeWhen(
                error: (_, __) => 'assets/images/m_profile/m_black.png',
                data: (p) => p.thumbUrl,
                orElse: () => 'assets/images/m_profile/m_black.png',
              );
    //날짜 포맷
    final created = st.post == null
        ? '09.17 17:47'
        : DateFormat('MM.dd HH:mm').format(
            tz.TZDateTime.from(st.post!.communityCreateDate.toUtc(), _seoul),
          );
    final body = st.post?.communityDetail ?? '게시글내용';

    return DefaultTabController(
      // TabBar/TabBarView 연결
      length: 2,
      child: Scaffold(
        appBar: CommonAppBar(),
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                //SliverToBoxAdapter제목,헤더,게시글 시작
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 15, 24, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //제목
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                        //작성자정보 날짜정보 프로필정보
                        _HeaderRow(
                          author: author,
                          createdAt: created,
                          authorImg: authorImg == ""
                              ? 'assets/images/m_profile/m_black.png'
                              : authorImg,
                        ),
                        const Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                        _PostBody(
                          body: body,
                        ),
                      ],
                    ),
                  ),
                ),

                //SliverToBoxAdapter 제목,헤더,게시글 끝
                const SliverToBoxAdapter(
                  child: Divider(thickness: 10, color: Color(0xFFEBEBEB)),
                ),
                //
                //SliverPersistentHeader 댓글해더 시작
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PlainHeaderDelegate(
                    height: 48,
                    child: Builder(
                      builder: (context) {
                        return _SortTabs(
                          onTap: (i) {
                            // 탭 전환 시 TabBarView도 함께 전환
                            final ctrl = DefaultTabController.of(context);
                            ctrl.animateTo(i);

                            // 정렬 스위치
                            final ord = i == 0
                                ? CommentOrder.latest
                                : CommentOrder.popular;
                            ref
                                .read(provider.notifier)
                                .refreshComments(ref, ord);
                          },
                        );
                      },
                    ),
                  ),
                ), //SliverPersistentHeader 댓글해더 끝
              ],
              body:
                  //댓글리스트
                  TabBarView(
                    children: [
                      //최신순
                      _pagedList(ref, st),
                      //추천순
                      _pagedList(ref, st),
                    ],
                  ),
            ),

            //댓글 입력창
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CommentWrite(
                commentController: commentController,
                submit: submit,
                currentUid: currentUid!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//헤더
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.author,
    required this.createdAt,
    required this.authorImg,
  });
  final String author;
  final String createdAt;
  final String authorImg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          SizedBox(
            height: 35,
            width: 35,
            child: Image.asset(authorImg),
          ),
          const SizedBox(width: 8),
          Text(author),
          const Spacer(),
          Text(createdAt),
        ],
      ),
    );
  }
}

//게시글
class _PostBody extends StatelessWidget {
  const _PostBody({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height 고정 대신 최소 높이 보장
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB8B8B8), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Text(body),
    );
  }
}

//해더댈리게이트(최신순추천순)
//SliverPersistentHeader 델리게이트 ---
//SliverPersistentHeader는 스크롤했을때 TabBar부분이 고정되게 해주는 어댑터
//SliverPersistentHeader를 쓰기위해 delegate로 정의하는 부분
class _PlainHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PlainHeaderDelegate({required this.child, required this.height});
  final Widget child;
  final double height;
  //header의 최소높이와 최대높이를 지정하는 부분
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: SizedBox(height: height, child: child),
    );
  }

  //델리게이트 리빌드 여부 결정, 탭바는 겨의 안바뀌니까 false
  @override
  bool shouldRebuild(covariant _PlainHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}

//최신순 추천순 위젯
class _SortTabs extends StatelessWidget {
  const _SortTabs({required this.onTap});
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final idx = controller.index;
        TextStyle style(bool selected) => TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.black : Colors.grey,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(0),
                child: Text('최신순', style: style(idx == 0)),
              ),
              const SizedBox(width: 8),
              const Text('|', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(1),
                child: Text('추천순', style: style(idx == 1)),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
