import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(categories.length, (index) {
            bool isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onCategorySelected(index),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    categories[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(
          height: 2,
          child: Row(
            children: List.generate(categories.length, (index) {
              return Expanded(
                child: Container(
                  color: selectedIndex == index
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
