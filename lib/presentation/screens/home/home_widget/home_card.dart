import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          color: const Color(0xFFD9D9D9),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 10,
              left: 15,
            ), // 카드 내부 전체 패딩
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 미션 $index',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      const Text(
                        '삼시세끼 다먹기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '#건강',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      GoRouter.of(context).go('/mission');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '미션하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(8, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF8F8F8F),
                                  size: 12,
                                ),
                              ),

                              Transform.translate(
                                offset: Offset(0, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF666666),
                                  size: 12,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(-8, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF342E37),
                                  size: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
