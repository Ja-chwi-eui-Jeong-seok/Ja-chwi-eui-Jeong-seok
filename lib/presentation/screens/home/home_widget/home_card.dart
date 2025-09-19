import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // 부모 Column 안에서 정상 렌더링
      physics: const NeverScrollableScrollPhysics(), // 부모 ScrollView에 위임
      itemCount: 1,
      itemBuilder: (context, index) {
        return Card(
          color: Color(0xFFD9D9D9),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text('오늘의 미션 $index', style: const TextStyle(fontSize: 16)),
            subtitle: const Text('삼시세끼 다먹기'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // // 상세 페이지 이동
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DetailPage(itemIndex: index),
                //   ),
                // );
              },
              child: const Text('상세보기 '),
            ),
          ),
        );
      },
    );
  }
}
