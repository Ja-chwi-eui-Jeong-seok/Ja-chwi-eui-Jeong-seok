// presentation/screens/community/vm/community_list_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ja_chwi/domain/entities/community.dart';
import 'package:ja_chwi/presentation/providers/community_usecase_provider.dart';

class CommunityListState {
  final List<Community> items;
  final bool isLoading;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
  const CommunityListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.lastDoc,
  });
  CommunityListState copyWith({
    List<Community>? items,
    bool? isLoading,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
  }) => CommunityListState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    lastDoc: lastDoc,
  );
}

class CommunityListVM extends Notifier<CommunityListState> {
  CommunityListVM(this.categoryCode, this.detailCode);
  late final Ref _ref = ref;
  final int categoryCode;
  final int detailCode;

  @override
  CommunityListState build() => const CommunityListState();

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    final (items, lastDoc, hasMore) = await _ref
        .read(fetchCommunitiesProvider)
        .call(
          categoryCode: categoryCode,
          categoryDetailCode: detailCode,
          limit: 10,
          startAfter: null,
          desc: true,
        );
    state = CommunityListState(
      items: items,
      lastDoc: lastDoc,
      hasMore: hasMore,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    final (items, lastDoc, hasMore) = await _ref
        .read(fetchCommunitiesProvider)
        .call(
          categoryCode: categoryCode,
          categoryDetailCode: detailCode,
          limit: 10,
          startAfter: state.lastDoc,
          desc: true,
        );
    state = CommunityListState(
      items: [...state.items, ...items],
      lastDoc: lastDoc,
      hasMore: hasMore,
      isLoading: false,
    );
  }
}

// Provider 팩토리: 탭별 code로 VM 생성
NotifierProvider<CommunityListVM, CommunityListState> communityListVmProvider({
  required int categoryCode,
  required int detailCode,
}) {
  return NotifierProvider<CommunityListVM, CommunityListState>(
    () => CommunityListVM(categoryCode, detailCode),
  );
}
