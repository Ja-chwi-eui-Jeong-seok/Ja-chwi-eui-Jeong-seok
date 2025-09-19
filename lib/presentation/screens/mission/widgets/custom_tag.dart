import 'package:flutter/material.dart';

class CustomTag extends StatelessWidget {
  final String label;
  const CustomTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Text(
        '#$label',
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }
}
