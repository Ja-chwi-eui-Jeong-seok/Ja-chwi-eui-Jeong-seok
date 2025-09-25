import 'package:flutter/foundation.dart';
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
    lastDoc: lastDoc ?? this.lastDoc,
  );
}

class CommunityListVM extends Notifier<CommunityListState> {
  CommunityListVM(this.categoryCode, this.detailCode, this.location);

  final int categoryCode;
  final int detailCode;
  final String? location;

  @override
  CommunityListState build() => const CommunityListState();
  //UI에서 스피너 조건 st.isLoading && st.hasMore 로 변경, 전에는 isLoading만 있어서수정함
  Future<void> loadInitial(WidgetRef ref) async {
    if (state.isLoading) return;
    //state = state.copyWith(isLoading: true); 2025.09.25 17시 이전 코드
    state = const CommunityListState(isLoading: true);
    try {
      final (items, lastDoc, hasMore) = await ref
          .read(fetchCommunitiesProvider)
          .call(
            categoryCode: categoryCode,
            categoryDetailCode: detailCode,
            location: location,
            limit: 10,
            startAfter: null,
            desc: true,
          );
      state = state.copyWith(items: items, lastDoc: lastDoc, hasMore: hasMore);
    } catch (e) {
      debugPrint('fetch error: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore(WidgetRef ref) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    final (items, lastDoc, hasMore) = await ref
        .read(fetchCommunitiesProvider)
        .call(
          categoryCode: categoryCode,
          categoryDetailCode: detailCode,
          location: location, // null 가능
          limit: 10,
          startAfter: state.lastDoc,
          desc: true,
        );

    state = CommunityListState(
      items: [...state.items, ...items],
      lastDoc: lastDoc ?? state.lastDoc,
      hasMore: hasMore && items.isNotEmpty, //빈 페이지면 종료
      isLoading: false,
    );
  }
}

/// provider 팩토리: (상위코드, 하위코드)별로 VM 생성
NotifierProvider<CommunityListVM, CommunityListState> communityListVmProvider({
  required int categoryCode,
  required int detailCode,
  String? location,
}) {
  return NotifierProvider<CommunityListVM, CommunityListState>(
    () => CommunityListVM(categoryCode, detailCode, location),
  );
}
