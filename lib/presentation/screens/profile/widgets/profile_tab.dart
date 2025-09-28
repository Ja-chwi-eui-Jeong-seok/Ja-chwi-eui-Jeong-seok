import 'package:flutter/material.dart';

class ProfileTap extends StatefulWidget {
  const ProfileTap({super.key});

  @override
  State<ProfileTap> createState() => _ProfileTapState();
}

class _ProfileTapState extends State<ProfileTap> {
  int selectedIndex = 0;

  final List<IconData> icons = [
    Icons.bookmark_outline, // 저장한 글
    Icons.edit_outlined,    // 내가 작성한 글
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 끝 패딩
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / icons.length;

          return SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // 1️⃣ 전체 하단 선 (연결된 바)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: Colors.grey[300],
                  ),
                ),
                // 2️⃣ 아이콘 Row
                Row(
                  children: List.generate(icons.length, (index) {
                    bool isSelected = index == selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[index],
                              size: 24,
                              color: isSelected ? Colors.black : Colors.grey,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                // 3️⃣ 선택된 탭 강조 바
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: selectedIndex * tabWidth,
                  width: tabWidth,
                  height: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: selectedIndex == 0
                            ? const Radius.circular(2)
                            : Radius.zero,
                        topRight: selectedIndex == icons.length - 1
                            ? const Radius.circular(2)
                            : Radius.zero,
                        bottomLeft: const Radius.circular(2),
                        bottomRight: const Radius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
