import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/providers/user_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widfet/comment_list.dart';

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
    Future.microtask(() => ref.read(provider.notifier).loadInitial(ref));
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

    final uid = ref.read(currentUidProvider);
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

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(provider);

    // 화면 헤더 데이터 구성
    final title = st.post?.communityName ?? '제목';
    final author = st.post?.createUser ?? '작성자';
    final created = st.post == null
        ? '09.17 17:47'
        : DateFormat('MM.dd HH:mm').format(st.post!.communityCreateDate);
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
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                        _HeaderRow(
                          // 기존 주석 유지
                          author: author,
                          created: created,
                        ),
                        const Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                        _PostBody(
                          // 기존 주석 유지
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
                      CommentList(
                        itemCount: st.comments.length,
                        likeCountOf: (i) => st.comments[i].likeCount,
                        nickOf: (i) =>
                            st.comments[i].uid, //TODO:UID 키로 닉네임가져와야함
                        textOf: (i) => st.comments[i].noteDetail,
                        loading: st.loadingComments,
                        isLikedOf: (i) =>
                            st.likedIds.contains(st.comments[i].id),
                        onToggleLike: (i) => ref
                            .read(provider.notifier)
                            .toggleLike(ref, st.comments[i].id),
                        createdAtOf: (i) =>
                            st.comments[i].createAt, // or .createdAt
                      ),
                      //추천순
                      CommentList(
                        itemCount: st.comments.length,
                        likeCountOf: (i) => st.comments[i].likeCount,
                        nickOf: (i) =>
                            st.comments[i].uid, //TODO:UID 키로 닉네임가져와야함
                        textOf: (i) => st.comments[i].noteDetail,
                        loading: st.loadingComments,
                        isLikedOf: (i) =>
                            st.likedIds.contains(st.comments[i].id),
                        onToggleLike: (i) => ref
                            .read(provider.notifier)
                            .toggleLike(ref, st.comments[i].id),
                        createdAtOf: (i) =>
                            st.comments[i].createAt, // or .createdAt
                      ),
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
  const _HeaderRow({required this.author, required this.created});
  final String author;
  final String created;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          SizedBox(
            height: 35,
            width: 35,
            child: Image.asset('assets/images/m_profile/m_black.png'),
          ),
          const SizedBox(width: 8),
          Text(author),
          const Spacer(),
          Text(created),
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

// 입력창
class CommentWrite extends StatelessWidget {
  const CommentWrite({
    super.key,
    required this.commentController,
    required this.submit,
  });
  final TextEditingController commentController;
  final VoidCallback submit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 키보드 높이만큼 올리기
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        elevation: 8,
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 그라데이션 (필요시 높이 조절)
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.fromARGB(0, 255, 255, 255), Colors.white],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 36,
                      width: 36,
                      //TODO: 사용자 이미지로 바꾸기
                      child: Image.asset('assets/images/m_profile/m_black.png'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: commentController,
                                minLines: 1,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '댓글을 입력하세요',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 46,
                              width: 64,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: GestureDetector(
                                onTap: submit,
                                child: const Center(
                                  child: Text(
                                    '확인',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
