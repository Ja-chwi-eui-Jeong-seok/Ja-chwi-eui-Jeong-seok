import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';

class CommunityDetailScreen extends StatefulWidget {
  CommunityDetailScreen({super.key});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  //댓글입력 컨트롤러
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void submit() {
    final text = commentController.text.trim();
    print(text);
    //firebase 게시글 키를 가지고 댓글에
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      // AppBar(
      //   title: const Row(children: [Text('커뮤니티'), Spacer(), Text('즐찾')]),
      // ),

      //바디영역
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
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
                    SizedBox(
                      height: 55,
                      child: Row(
                        children: [
                          //프로필 이미지
                          SizedBox(
                            height: 35,
                            width: 35,
                            child: Image.asset(
                              'assets/images/m_profile/m_black.png',
                            ),
                          ),
                          SizedBox(width: 8),
                          //작성자 닉네임
                          Text('작성자'),
                          Spacer(),
                          //작성날짜
                          Text('09.17 17:47'),
                        ],
                      ),
                    ),
                    Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                    _PostBody(),
                  ],
                ),
              ),
              Divider(thickness: 10, color: Color(0xFFEBEBEB)),
              Expanded(
                //댓글목록 최신순 추천순 정렬 탭바
                child: DefaultTabController(
                  length: 2,

                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: TabBar(
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: '최신순'),
                            Tab(text: '추천순'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            //정렬 메서느 추가해서 전달할지?
                            //댓글 불러온 다음에 화면에서 정렬(기본값은 최신순)
                            //최신순
                            CommentCard(itemCount: 10),

                            //추천순
                            CommentCard(itemCount: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          //댓글입력영역
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
      // //댓글입력영역
      // bottomSheet: CommentWrite(
      //   commentController: commentController,
      //   submit: submit,
      // ),
    );
  }
}

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
      // 키보드 올라오면 같이 올림
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Material(
        elevation: 8,
        type: MaterialType.transparency, // Material은 투명
        child: Ink(
          // 여기서 gradient 적용
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(0, 255, 255, 255),
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(25),

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
                            // TextFormField 필수
                            child: TextFormField(
                              controller: commentController,
                              minLines: 1,
                              maxLines: 6, // 자동 줄 증가
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
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            height: 46,
                            width: 64,
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
          ),
        ),
      ),
    );
  }
}

//작성된 글 영역
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
      //작성 내용 인자로 받아와야함
      child: Text('오늘 청소하는데 얼룩이 잘 안지워지더라구요...'),
    );
  }
}

//댓글 카드
//댓글들 리스트로 받아와야함
class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: itemCount,
      //itemExtent: 80, // 고정 높이로 성능 향상
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        return SizedBox(
          height: 80,
          child: Row(
            children: [
              //댓글작성자 프로필 이미지
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
                  children: const [
                    //userNickname String
                    Text('닉네임', style: TextStyle(fontWeight: FontWeight.w600)),
                    //comment String
                    Text(
                      '댓글내용입니다 댓글을 입력해주세요',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              //게시글에 좋아요 한 유저 리스트에 추가
              HeartButton(),
            ],
          ),
        );
      },
    );
  }
}

class HeartButton extends StatefulWidget {
  const HeartButton({super.key});
  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool isLiked = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
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
