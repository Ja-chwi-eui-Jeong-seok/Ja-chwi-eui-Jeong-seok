import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  const CommunityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Text('커뮤니티'), Spacer(), Text('즐찾')]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 15, 24, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '제목',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Divider(thickness: 2, color: Color(0xFFEBEBEB)),
                SizedBox(
                  height: 55,
                  child: Row(
                    children: [
                      Text('프로필이미지'),
                      SizedBox(width: 8),
                      Text('작성자'),
                      Spacer(),
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
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: const [
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
                        CommentCard(itemCount: 10),
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
    );
  }
}

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
      child: const Text('오늘 청소하는데 얼룩이 잘 안지워지더라구요...'),
    );
  }
}

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
              CircleAvatar(radius: 16),
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
