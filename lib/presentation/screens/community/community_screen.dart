import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
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
          bottom: const TabBar(
            indicator: UnderlineTabIndicator(
              insets: EdgeInsets.zero,
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            isScrollable: false,
            labelPadding: EdgeInsets.symmetric(horizontal: 16),
            indicatorWeight: 3,
            tabs: [
              Tab(text: '요리'),
              Tab(text: '청소'),
              Tab(text: '운동'),
              Tab(text: '미션'),
              Tab(child: Text('자유')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            //TODO:카테고리템 이름, 게시글 리스트
            _CategoryTab(),
            _CategoryTab(),
            _CategoryTab(),
            _CategoryTab(),
            _CategoryTab(),
          ],
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
  const _CategoryTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                '제목',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _PlaceholderCard(),
              SizedBox(height: 12),
              _PlaceholderCard(),
              SizedBox(height: 12),
            ],
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
      height: 88,
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
