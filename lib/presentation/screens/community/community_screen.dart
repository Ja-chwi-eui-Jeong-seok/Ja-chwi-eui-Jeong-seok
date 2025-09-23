import 'package:flutter/material.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = ['자유', '요리', '청소', '운동', '미션', '산책'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar:
            //CommonAppBar(),
            AppBar(
              titleSpacing: 10,
              title: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                  const SizedBox(width: 4),
                  const Text('동작구'),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),
              bottom: TabBar(
                padding: EdgeInsets.symmetric(horizontal: 16),
                indicator: UnderlineTabIndicator(
                  //  insets: EdgeInsets.zero,
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                isScrollable: false,
                //labelPadding: EdgeInsets.symmetric(horizontal: 16),
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                tabs: tabs.map((e) => Tab(text: e)).toList(),
              ),
            ),
        body: Container(
          padding: EdgeInsets.only(left: 24, right: 24, top: 18),
          child: TabBarView(
            children:
                //TODO:카테고리템 이름, 게시글 리스트
                //TODO: 카테고리별 게시글정보들 어떻게 넣을것인지
                tabs.map((e) {
                  return _CategoryTab(e);
                }).toList(),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 55,
          height: 55,
          child: FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _SortChip(text: '최신순', selected: true),
              const SizedBox(width: 8),
              _SortChip(text: '추천순', selected: false),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(top: 8),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return _PlaceholderCard();
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12); // 아이템 사이 간격
            },
          ),
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String text;
  final bool selected;
  const _SortChip({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.grey;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (text == '최신순')
          const Text('  |  ', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// class _AddCard extends StatelessWidget {
//   const _AddCard();

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         height: 88,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFD9D9D9)),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.add, size: 20, color: Colors.grey),
//               SizedBox(height: 4),
//               Text('대화방을 추가해주세요', style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
