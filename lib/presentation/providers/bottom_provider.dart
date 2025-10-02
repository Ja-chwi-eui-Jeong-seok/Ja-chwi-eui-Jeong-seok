// lib/presentation/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 프로필 탭 선택 상태 관리
final selectedTabProvider = StateProvider<int>((ref) => 0);