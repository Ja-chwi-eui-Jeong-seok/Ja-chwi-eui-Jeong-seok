import 'package:flutter/material.dart';

class ProfileTap extends StatefulWidget {
  const ProfileTap({super.key});

  @override
  State<ProfileTap> createState() => _ProfileTapState();
}

class _ProfileTapState extends State<ProfileTap> {
  int selectedIndex = 0;

  final List<IconData> icons = [
    Icons.bookmark_outline,
    Icons.favorite_outline,
    Icons.edit_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(icons.length, (index) {
        bool isSelected = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(            
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    size: 24,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
