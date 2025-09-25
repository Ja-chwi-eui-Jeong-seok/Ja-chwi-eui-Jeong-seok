import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  // ✅ 라우터에서 id를 extra로 넘김: context.push('/community-detail', extra: x.id)
  const CommunityDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final commentController = TextEditingController();

  // ✅ 상세 VM 프로바이더 인스턴스 보관
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

  void submit() {
    if (!mounted) return;
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    //게시글 id > firebase에 등록
    // TODO: 댓글 생성 UseCase 연결 (닉네임/uid 주입)
    if (kDebugMode) {
      print('create comment to post=${widget.id}, text=$text');
    }
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
    final body = st.post?.communityDetail ?? '오늘 청소하는데 얼룩이 잘 안지워지더라구요...';

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
                //최신순 추천선
                SliverPersistentHeader(
                  //SliverPersistentHeader 델리게이트필요
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      // 탭 변경 시 정렬 스위치
                      onTap: (i) {
                        final ord = i == 0
                            ? CommentOrder.latest
                            : CommentOrder.popular;
                        ref.read(provider.notifier).refreshComments(ref, ord);
                      },
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: '최신순'),
                        Tab(text: '추천순'),
                      ],
                    ),
                  ),
                ), //SliverPersistentHeader 댓글해더 끝
              ],
              body:
                  //댓글리스트
                  TabBarView(
                    children: [
                      //최신순
                      _CommentList(
                        itemCount: st.comments.length,
                        likeCountOf: (i) => st.comments[i].likeCount,
                        nickOf: (i) => st.comments[i].nickName,
                        textOf: (i) => st.comments[i].noteDetail,
                        loading: st.loadingComments,
                      ),
                      //추천순
                      _CommentList(
                        itemCount: st.comments.length,
                        likeCountOf: (i) => st.comments[i].likeCount,
                        nickOf: (i) => st.comments[i].nickName,
                        textOf: (i) => st.comments[i].noteDetail,
                        loading: st.loadingComments,
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

//SliverPersistentHeader 델리게이트 ---
//SliverPersistentHeader는 스크롤했을때 TabBar부분이 고정되게 해주는 어댑터
//SliverPersistentHeader를 쓰기위해 delegate로 정의하는 부분
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  //header의 최소높이와 최대높이를 지정하는 부분
  @override
  double get minExtent => tabBar.preferredSize.height; //48px
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  //델리게이트 리빌드 여부 결정, 탭바는 겨의 안바뀌니까 false
  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => false;
}

// --- 댓글 리스트 ---
// 기존 CommentCard의 주석과 형태를 유지하되, VM 데이터로 교체
class _CommentList extends StatelessWidget {
  const _CommentList({
    required this.itemCount,
    required this.nickOf,
    required this.textOf,
    required this.likeCountOf,
    required this.loading,
  });

  final int itemCount;
  final String Function(int) nickOf;
  final String Function(int) textOf;
  final int Function(int) likeCountOf;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // 중요: 스크롤은 ListView가 맡게 (shrinkWrap/physics 건드리지 않기)
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: const [
                      Text('공유하기'),
                      Spacer(),
                      Icon(Icons.share),
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
              case 'share':
                // 공유 처리
                // Share.share('공유할 내용'); // share_plus 사용 시
                break;
              case null:
                // 메뉴 밖을 눌러 닫힘. 아무것도 하지 않음.
                break;
            }
          },
          child: Container(
            color: Colors.white,
            height: 80,
            child: Row(
              children: [
                SizedBox(
                  height: 45,
                  width: 45,
                  child: Image.asset('assets/images/m_profile/m_black.png'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickOf(i),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        textOf(i),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _HeartButton(count: likeCountOf(i)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeartButton extends StatefulWidget {
  const _HeartButton({required this.count});
  final int count;

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  bool isLiked = false;
  late int likeCount = widget.count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52, // 카운트 공간 확보
      height: 32,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
                likeCount += isLiked ? 1 : -1;
              });
              // TODO: repo.incLike(commentId, isLiked ? +1 : -1) 연결
            },
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.black,
              size: 20,
            ),
          ),
          Text('$likeCount'),
        ],
      ),
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
