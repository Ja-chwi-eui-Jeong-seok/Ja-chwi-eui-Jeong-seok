import 'package:flutter/material.dart';

class PublicToggleSwitch extends StatelessWidget {
  final bool isPublic;
  final VoidCallback onToggle;

  const PublicToggleSwitch({
    super.key,
    required this.isPublic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          '공개 여부',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 70,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: isPublic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  child: Container(
                    width: 45,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isPublic ? Colors.black : Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        isPublic ? 'ON' : 'OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
