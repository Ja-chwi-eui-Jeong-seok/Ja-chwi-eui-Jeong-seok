import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart.dart';

class NickName extends ConsumerWidget {
  const NickName({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final av = ref.watch(profileByUidProvider(uid));
    return av.when(
      data: (p) => Text(p.nickname.isNotEmpty ? p.nickname : '익명'),
      loading: () => const SizedBox(width: 30, height: 12),
      error: (_, __) => const Text('—'),
    );
  }
}
