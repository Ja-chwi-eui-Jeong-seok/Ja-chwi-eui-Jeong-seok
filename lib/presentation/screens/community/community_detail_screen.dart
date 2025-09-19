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
                //SliverToBoxAdapter 댓글영역 시작
                //최신순 추천선
                SliverPersistentHeader(
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
                ),
              ],
              body:
                  //댓글리스트
                  TabBarView(
                    children: [
                      CommentCard(itemCount: 20),
                      CommentCard(itemCount: 20),
                    ],
                  ),
              //SliverToBoxAdapter 댓글영역 끝
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

// --- 헤더 보조 위젯들 ---
class _HeaderRow extends StatelessWidget {
  _HeaderRow({super.key});
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

class _PostBody extends StatelessWidget {
  _PostBody({super.key});
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

// --- SliverPersistentHeader 델리게이트 ---
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  double get minExtent => tabBar.preferredSize.height;
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
        return SizedBox(
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
                    Text('닉네임', style: TextStyle(fontWeight: FontWeight.w600)),
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
        );
      },
    );
  }
}

class _HeartButton extends StatefulWidget {
  _HeartButton({super.key});
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

// --- 입력창(그라데이션 포함) ---
class CommentWrite extends StatelessWidget {
  CommentWrite({
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
