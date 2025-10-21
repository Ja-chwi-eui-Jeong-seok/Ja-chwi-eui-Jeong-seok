import 'package:flutter/material.dart';

class ProfileTap extends StatefulWidget {
  final void Function(int index) onTabChanged;

  const ProfileTap({super.key, required this.onTabChanged});

  @override
  State<ProfileTap> createState() => _ProfileTapState();
}

class _ProfileTapState extends State<ProfileTap> {
  int selectedIndex = 0;

  final List<IconData> icons = [
    Icons.bookmark_outline,
    Icons.border_color,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / icons.length;

          return SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // 전체 밑줄
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: Colors.grey[300],
                  ),
                ),
                // 탭
                Row(
                  children: List.generate(icons.length, (index) {
                    bool isSelected = index == selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          widget.onTabChanged(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.transparent, // 터치 영역 확보
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 아이콘 주변 박스
                              Container(
                                width: (icons.length * 2),
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icons[index],
                                  size: 24,
                                  color: isSelected ? Colors.black : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // 선택된 밑줄
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
