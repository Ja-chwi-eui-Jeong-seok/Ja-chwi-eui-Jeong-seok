import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/repositories/help_repository_impl.dart';
import 'package:ja_chwi/domain/repositories/help_repository.dart';
import 'package:ja_chwi/domain/entities/help_entity.dart';


// Repository Provider
final helpRepositoryProvider = Provider<HelpRepository>((ref) {
  return HelpRepositoryImpl(FirebaseFirestore.instance);
});

// Stream Provider for Help list
final helpListProvider = StreamProvider<List<HelpEntity>>((ref) {
  final repo = ref.watch(helpRepositoryProvider);
  return repo.getHelps();
});
