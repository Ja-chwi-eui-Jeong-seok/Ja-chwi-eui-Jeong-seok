import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoLocationView extends StatelessWidget {
  const NoLocationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 36, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('위치가 등록되지 않았습니다.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/profile'), //TODO:경로
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('위치 등록하러 가기'),
          ),
        ],
      ),
    );
  }
}
