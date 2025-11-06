import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/core/constants/app_colors.dart';
import 'package:ja_chwi/core/constants/app_sizes.dart';
import 'package:ja_chwi/domain/entities/category.dart';
import 'package:ja_chwi/presentation/common/utils/string_utils.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/category_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/no_location_view.dart';
import 'package:ja_chwi/presentation/widgets/bottom_nav.dart';
import 'package:ja_chwi/domain/entities/community.dart';

//커뮤니티 화면 (카테고리 탭 2단구조 + 게시글 패치)
class CommunityScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const CommunityScreen({super.key, this.extra});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(categoryVMProvider);

    // 프로필 통해 위치 얻기
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profileAv = uid == null
        ? const AsyncValue.loading()
        : ref.watch(profileByUidProvider(uid));
    final String? location = profileAv.maybeWhen(
      data: (p) => p.dongName,
      orElse: () => null,
    );
    final hasLocation = (location != null && location.isNotEmpty);

    return catState.parents.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('카테고리 오류: $e'))),
      data: (parents) {
        if (parents.isEmpty) {
          return const Scaffold(body: Center(child: Text('카테고리가 없습니다')));
        }
        //오름차순 정렬
        parents.sort((a, b) => a.categoryCode.compareTo(b.categoryCode));
        return DefaultTabController(
          length: parents.length + 1, // "전체" 탭 추가
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 10,
              title: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                  const SizedBox(width: 4),
                  Text(location ?? '위치를 등록해주세요'),
                  const Spacer(),
                ],
              ),
              bottom: TabBar(
                isScrollable: false,
                unselectedLabelStyle: const TextStyle(
                  fontSize: AppSizes.fontSizeL,
                ),
                unselectedLabelColor: AppColors.grey,
                labelStyle: const TextStyle(
                  fontSize: AppSizes.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
                labelColor: AppColors.primary,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: AppColors.primary, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  const Tab(
                    text: '전체',
                  ), // "전체" 탭 추가
                  ...parents.map((p) => Tab(text: p.categoryName)),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // "전체" 탭 뷰
                hasLocation
                    ? _AllPostsView(location: location, extra: widget.extra)
                    : const NoLocationView(),
                // 기존 카테고리 탭 뷰들
                ...parents.map((p) {
                  return hasLocation
                      ? _SecondDepthTabs(
                          parentCode: p.categoryCode,
                          location: location,
                          extra: widget.extra,
                        )
                      : const NoLocationView();
                }),
              ],
            ),
            floatingActionButton: FloatingActionButton.small(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다.')),
                  );
                  return;
                }
                if (!hasLocation) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('위치 등록 후 글쓰기가 가능합니다.')),
                  );
                  return;
                }
                context.push('/community-create', extra: widget.extra);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: Icon(
                Icons.edit,
                size: AppSizes.iconS,
              ),
            ),
            bottomNavigationBar: BottomNav(
              mode: BottomNavMode.tab,
              userData:
                  GoRouterState.of(context).extra as Map<String, dynamic>?,
            ),
          ),
        );
      },
    );
  }
}

/// 상위 탭(부모 카테고리) → 하위 탭(세부 카테고리)을 표시하는 위젯
class _SecondDepthTabs extends ConsumerStatefulWidget {
  const _SecondDepthTabs({
    required this.parentCode,
    required this.location,
    required this.extra,
  });
  final int parentCode;
  final String? location;
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<_SecondDepthTabs> createState() => _SecondDepthTabsState();
}

class _SecondDepthTabsState extends ConsumerState<_SecondDepthTabs> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 처음 뜰 때 하위 카테고리 로드 (한 번만 실행됨)
    if (!_requested) {
      _requested = true;
      Future.microtask(
        () => ref
            .read(categoryVMProvider.notifier)
            .loadChildren(widget.parentCode),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 상위 카테고리 상태에서, 선택한 parentCode 의 children 가져오기
    final state = ref.watch(categoryVMProvider);
    final av = state.children[widget.parentCode];
    //아직 없으면 로딩표시
    if (av == null || av.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    //하위 카테고리 데이터처리
    return av.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('하위 카테고리 오류: $e')),
      data: (subs) {
        if (subs.isEmpty) {
          return const Center(child: Text('하위 카테고리가 없습니다'));
        }
        subs.sort(
          (a, b) => a.categoryDetailCode.compareTo(b.categoryDetailCode),
        );
        return DefaultTabController(
          length: subs.length,
          child: Column(
            children: [
              //두번째 탭바
              _CategoryDetailChips(subs: subs),
              // 하위 탭뷰: 각 하위 카테고리의 게시글 리스트 영역(placeholder)
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: subs.map((s) {
                    return _PostsPlaceholder(
                      parentCode: widget.parentCode,
                      detailCode: s.categoryDetailCode,
                      detailName: s.categoryDetailName,
                      location: widget.location,
                      extra: widget.extra,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 게시글 목록 표시
class _PostsPlaceholder extends ConsumerStatefulWidget {
  const _PostsPlaceholder({
    required this.parentCode,
    required this.detailCode,
    required this.detailName,
    required this.location,
    required this.extra,
  });
  final int parentCode;
  final int detailCode;
  final String detailName;
  final String? location;
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<_PostsPlaceholder> createState() => _PostsPlaceholderState();
}

class _PostsPlaceholderState extends ConsumerState<_PostsPlaceholder> {
  late NotifierProvider<CommunityListVM, CommunityListState> provider;
  bool _ready = false;
  ProviderSubscription<int>? _changedSub;

  @override
  void initState() {
    super.initState();
    _maybeInitProviderAndLoad();
    _changedSub = ref.listenManual<int>(
      communityChangedTickProvider,
      (prev, next) {
        ref.invalidate(provider);
        Future.microtask(() {
          ref.read(provider.notifier).loadInitial(ref);
        });
      },
    );
  }

  @override
  void dispose() {
    _changedSub?.close();
    super.dispose();
  }

  void _maybeInitProviderAndLoad() {
    final loc = widget.location;
    if (loc == null || loc.isEmpty) return;

    provider = communityListVmProvider(
      categoryCode: widget.parentCode,
      detailCode: widget.detailCode,
      location: loc,
    );
    _ready = true;

    Future.microtask(() {
      if (!mounted) return;
      ref.read(provider.notifier).loadInitial(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const NoLocationView();

    final st = ref.watch(provider);
    if (st.items.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Row(
                children: [
                  Text(
                    widget.detailName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: st.isLoading
                    ? const CircularProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Text(
                          '아직 게시글이 없습니다',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (!st.hasMore || st.isLoading) return false;
          if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.9) {
            ref.read(provider.notifier).loadMore(ref);
          }
          return false;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Row(
                children: [
                  Text(
                    widget.detailName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: AppSizes.paddingL,
                  right: AppSizes.paddingL,
                  bottom: 100,
                ),
                itemCount:
                    st.items.length + ((st.isLoading && st.hasMore) ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  if (i >= st.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final post = st.items[i];
                  return _PostListItem(post: post, extra: widget.extra);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDetailChips extends StatelessWidget {
  const _CategoryDetailChips({required this.subs});
  final List<CategoryDetail> subs;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        final current = controller.index;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMS,
            vertical: AppSizes.paddingS,
          ),
          child: Row(
            children: List.generate(subs.length, (i) {
              final s = subs[i];
              final selected = (current == i);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () => controller.animateTo(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.white, // 선택 배경
                      border: Border.all(color: AppColors.grey), // 항상 테두리
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      s.categoryDetailName,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.white
                            : AppColors.grey, // 선택 글자색
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// "전체" 탭 뷰 - 모든 카테고리의 게시글을 표시
class _AllPostsView extends ConsumerStatefulWidget {
  const _AllPostsView({required this.location, this.extra});
  final String? location;
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<_AllPostsView> createState() => _AllPostsViewState();
}

class _AllPostsViewState extends ConsumerState<_AllPostsView> {
  late NotifierProvider<CommunityListVM, CommunityListState> provider;
  bool _ready = false;
  ProviderSubscription<int>? _changedSub;

  @override
  void initState() {
    super.initState();
    _maybeInitProviderAndLoad();
    _changedSub = ref.listenManual<int>(
      communityChangedTickProvider,
      (prev, next) {
        ref.invalidate(provider);
        Future.microtask(() {
          ref.read(provider.notifier).loadInitial(ref);
        });
      },
    );
  }

  @override
  void dispose() {
    _changedSub?.close();
    super.dispose();
  }

  void _maybeInitProviderAndLoad() {
    final loc = widget.location;
    if (loc == null || loc.isEmpty) return;

    provider = communityListVmProvider(
      categoryCode: null, // 모든 카테고리
      detailCode: null, // 모든 하위 카테고리
      location: loc,
    );
    _ready = true;

    Future.microtask(() {
      if (!mounted) return;
      ref.read(provider.notifier).loadInitial(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const NoLocationView();

    final st = ref.watch(provider);

    if (st.items.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Row(
                children: [
                  Text(
                    '전체',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: st.isLoading
                    ? const CircularProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Text(
                          '아직 게시글이 없습니다',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (!st.hasMore || st.isLoading) return false;
          if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.9) {
            ref.read(provider.notifier).loadMore(ref);
          }
          return false;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              child: Row(
                children: [
                  Text(
                    '전체',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: AppSizes.paddingL,
                  right: AppSizes.paddingL,
                  bottom: 100,
                ),
                itemCount:
                    st.items.length + ((st.isLoading && st.hasMore) ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  if (i >= st.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final post = st.items[i];
                  return _PostListItem(post: post, extra: widget.extra);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostListItem extends ConsumerWidget {
  const _PostListItem({
    required this.post,
    required this.extra,
  });

  final Community post;
  final Map<String, dynamic>? extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateFormat(
      'yyyy.MM.dd',
    ).format(post.communityCreateDate.toLocal());
    final pvs = ref.watch(profileByUidProvider(post.createUser));

    final (pvImg, nickName) = pvs.when<(String, String)>(
      data: (p) => (p.imageFullUrl, p.nickname),
      loading: () => ('assets/images/profile/black.png', '집먼지'),
      error: (_, __) => ('assets/images/profile/black.png', '집먼지'),
    );

    final countAv = ref.watch(commentCountByPostProvider(post.id));
    Widget commentCount = countAv.when(
      data: (c) => Text(
        '$c',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      loading: () => const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Text(
        '0',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    return InkWell(
      onTap: () async {
        final result = await context.push<bool>(
          '/community-detail',
          extra: {'id': post.id, 'extra': extra},
        );

        if (result == true) {
          ref.read(communityChangedTickProvider.notifier).state++;
        }
      },
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.postBorder,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              StringUtils.truncateWithEllipsis(
                                15,
                                post.communityName,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              date,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              nickName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.mode_comment_outlined,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            commentCount,
                            const SizedBox(width: 10),
                            _BookmarkIcon(
                              postId: post.id,
                              authorUid: post.createUser,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 220,
              top: 50,
              child: IgnorePointer(
                child: ClipRect(
                  child: Align(
                    child: Opacity(
                      opacity: 0.35,
                      child: Image.asset(
                        pvImg,
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 북마크 아이콘 위젯
class _BookmarkIcon extends ConsumerWidget {
  const _BookmarkIcon({required this.postId, required this.authorUid});
  final String postId;
  final String authorUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkStatusAsync = ref.watch(isBookmarkedProvider(postId));

    return bookmarkStatusAsync.when(
      data: (isBookmarked) => Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        size: AppSizes.iconS,
        color: isBookmarked ? AppColors.primary : AppColors.grey,
      ),
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(
        Icons.bookmark_border,
        size: AppSizes.iconS,
        color: AppColors.grey,
      ),
    );
  }
}
