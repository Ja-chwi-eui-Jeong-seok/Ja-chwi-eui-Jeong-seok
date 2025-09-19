import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';

class CommunityDetailScreen extends StatelessWidget {
  CommunityDetailScreen({super.key});
  //댓글입력 컨트롤러
  final commentController = TextEditingController();

  void submit() {
    Text(commentController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      // AppBar(
      //   title: const Row(children: [Text('커뮤니티'), Spacer(), Text('즐찾')]),
      // ),

      //바디영역
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 15, 24, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제목',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          const Divider(thickness: 10, color: Color(0xFFEBEBEB)),
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
      bottomSheet: Padding(
        // 키보드 올라오면 같이 올림
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          elevation: 8,
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: Image.asset('assets/images/m_profile/m_black.png'),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: [
                      Expanded(
                        // TextFormField 필수
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: commentController,
                            minLines: 1,
                            maxLines: 6, // 자동 줄 증가
                            decoration: InputDecoration(
                              hintText: '댓글을 입력하세요',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        width: 64,
                        child: ElevatedButton(
                          onPressed: submit,
                          child: const Text('확인'),
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.all(8),
      //작성 내용 인자로 받아와야함
      child: const Text('오늘 청소하는데 얼룩이 잘 안지워지더라구요...'),
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
                    Text('닉네임', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '댓글내용입니다 댓글을 입력해주세요',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const HeartButton(),
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
