import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:ja_chwi/presentation/screens/mission/core/providers/mission_providers.dart';

final profileByUidProvider = StreamProvider.family<Profile, String>((ref, uid) {
  final usecase = ref.watch(fetchUserProfileUseCaseProvider);
  // usecase.execute(uid) => Stream<Map<String, dynamic>>
  return usecase.execute(uid).map(Profile.fromJson);
});
