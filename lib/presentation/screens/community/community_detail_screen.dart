import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key});
  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void submit() {
    if (!mounted) return;
    final text = commentController.text.trim();
    print(text);
    //게시글 id > firebase에 등록
  }

  @override
  Widget build(BuildContext context) {
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
                          '제목',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                        _HeaderRow(),
                        Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                        _PostBody(),
                      ],
                    ),
                  ),
                ),

                //SliverToBoxAdapter 제목,헤더,게시글 끝
                SliverToBoxAdapter(
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
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
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
                      CommentCard(itemCount: 20),
                      //추천순
                      CommentCard(itemCount: 20),
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
  const _HeaderRow({super.key});
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
          SizedBox(width: 8),
          Text('작성자'),
          Spacer(),
          Text('09.17 17:47'),
        ],
      ),
    );
  }
}

//게시글
class _PostBody extends StatelessWidget {
  const _PostBody({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB8B8B8), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(8),
      child: Text('오늘 청소하는데 얼룩이 잘 안지워지더라구요...'),
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
class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    // 중요: 스크롤은 ListView가 맡게 (shrinkWrap/physics 건드리지 않기)
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
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
                    children: [
                      Text('신고하기'),
                      SizedBox(
                        width: 50,
                      ),
                      Spacer(),
                      Icon(Icons.notifications_none),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Text('차단하기'),
                      Spacer(),
                      Icon(Icons.do_not_disturb_on_outlined),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
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
            ;
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
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '닉네임',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '댓글내용입니다 댓글을 입력해주세요',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _HeartButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeartButton extends StatefulWidget {
  const _HeartButton({super.key});
  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  bool isLiked = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        onPressed: () => setState(() => isLiked = !isLiked),
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.black,
          size: 20,
        ),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.fromARGB(0, 255, 255, 255), Colors.white],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: Image.asset('assets/images/m_profile/m_black.png'),
                    ),
                    SizedBox(width: 8),
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
                                decoration: InputDecoration(
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
                                child: Center(
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
