// presentation/providers/community_usecase_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/domain/repositories/community_repository.dart';
import 'package:ja_chwi/data/repositories/community_repository_impl.dart';
import 'package:ja_chwi/data/datasources/community_data_source_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/usecases/create_community.dart';
import 'package:ja_chwi/domain/usecases/fetch_communities.dart';
import 'package:ja_chwi/domain/usecases/soft_delete_community.dart';
import 'package:ja_chwi/domain/usecases/update_community.dart';

// DS
final communityDsProvider = Provider(
  (ref) => CommunityDataSourceImpl(FirebaseFirestore.instance),
);
// Repo
final communityRepoProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepositoryImpl(ref.read(communityDsProvider)),
);

// UseCases
final createCommunityProvider = Provider(
  (ref) => CreateCommunity(ref.read(communityRepoProvider)),
);
final fetchCommunitiesProvider = Provider(
  (ref) => FetchCommunities(ref.read(communityRepoProvider)),
);
final updateCommunityProvider = Provider(
  (ref) => UpdateCommunity(ref.read(communityRepoProvider)),
);
final softDeleteCommunityProvider = Provider(
  (ref) => SoftDeleteCommunity(ref.read(communityRepoProvider)),
);
