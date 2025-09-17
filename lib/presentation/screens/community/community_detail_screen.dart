import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  CommunityDetailScreen({super.key});
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text('커뮤니티'), Spacer(), Text('즐찾')]),
      ),
      body: Column(
        children: [
          //게시글 영역
          Container(
            padding: EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFB8B8B8), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '오늘 청소하는데 얼룩이 잘 안지워지더라구요 이럴떈 어떤 것을 사용해야 잘 지워질수있을까요?',
                    ),
                  ),
                ),
              ],
            ),
          ),
          //구분선
          Divider(
            thickness: 10, // 선 굵기
            color: Color(0xFFEBEBEB), // 색상
          ),
          //댓글영역
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicator: UnderlineTabIndicator(
                      //  insets: EdgeInsets.zero,
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    tabs: [
                      Tab(text: '최신순'),
                      Tab(text: '추천순'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [Text('최신순 댓글'), Text('추천순 댓글')],
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
