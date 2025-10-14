import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/data/datasources/add_mission_datasource.dart';
import 'package:ja_chwi/data/repositories/add_mission_repository_impl.dart';
import 'package:ja_chwi/domain/entities/add_mission_entity.dart';

final addMissionRepositoryProvider = Provider(
  (ref) => AddMissionRepositoryImpl(AddMissionDataSource(FirebaseFirestore.instance)),
);

final addMissionListProvider = StreamProvider<List<AddMissionEntity>>((ref) {
  return ref.watch(addMissionRepositoryProvider).getMissions();
});
