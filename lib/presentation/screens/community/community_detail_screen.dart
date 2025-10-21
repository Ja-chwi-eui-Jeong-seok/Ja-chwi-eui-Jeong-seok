import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ja_chwi/core/constants/app_colors.dart';
import 'package:ja_chwi/presentation/common/app_bar_titles.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/data/datasources/comment_data_source.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/app_confirm_dialog.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/comment_list.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/community_detail_screen_widget/comment_write.dart';

/// CommunityDetailScreen
/// 삭제/수정 후 호출 화면으로 돌아가면서 reload 가능하도록 수정됨
class CommunityDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  final String id;

  const CommunityDetailScreen({super.key, required this.id, this.extra});

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final commentController = TextEditingController();
  final commentFocusNode = FocusNode();

  // 상세 VM 프로바이더 인스턴스 보관
  late final provider = communityDetailVmProvider(widget.id);

  @override
  void initState() {
    super.initState();
    // 첫 진입 시 단건 게시글 + 댓글 초기 로드
    Future.microtask(() => ref.read(provider.notifier).loadInitial(ref));
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  /// 댓글 입력
  Future<void> submit() async {
    if (!mounted) return;
    final text = commentController.text.trim();

    // 빈값 가드
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('댓글을 입력하세요')));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    await ref.read(provider.notifier).createComment(
          ref,
          uid: uid,
          text: text,
        );

    if (!mounted) return;
    commentController.clear();
  }

  /// 댓글 리스트
  Widget _pagedList(WidgetRef ref, CommunityDetailState st) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollUpdateNotification) {
          final remain = n.metrics.maxScrollExtent - n.metrics.pixels;
          if (remain < 200 && !st.loadingComments && st.hasMore) {
            ref.read(provider.notifier).loadMore(ref);
          }
        }
        return false;
      },
      child: CommentList(
        itemCount: st.comments.length,
        likeCountOf: (i) => st.comments[i].likeCount,
        uidOf: (i) => st.comments[i].uid,
        textOf: (i) => st.comments[i].noteDetail,
        loading: st.loadingComments,
        isLikedOf: (i) => st.likedIds.contains(st.comments[i].id),
        onToggleLike: (i) =>
            ref.read(provider.notifier).toggleLike(ref, st.comments[i].id),
        createdAtOf: (i) => st.comments[i].createAt,
        comments: st.comments,
        detailVmProvider: provider,
        commentFocusNode: commentFocusNode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(provider);

    // Community 목록 변경 시 자동 reload
    ref.listen<int>(communityChangedTickProvider, (_, __) {
      ref.read(provider.notifier).loadInitial(ref);
    });

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // 게시글 작성자가 현재 유저인지
    final isOwner =
        st.post != null && currentUid != null && st.post!.createUser == currentUid;

    // 게시글 정보
    final title = st.post?.communityName ?? '제목';
    final authorUid = st.post?.createUser;
    final author = authorUid == null
        ? '작성자'
        : ref
              .watch(profileByUidProvider(authorUid))
              .maybeWhen(data: (p) => p.nickname, orElse: () => '작성자');
    final authorImg = authorUid == null
        ? 'assets/images/m_profile/m_black.png'
        : ref
              .watch(profileByUidProvider(authorUid))
              .maybeWhen(
                error: (_, __) => 'assets/images/m_profile/m_black.png',
                data: (p) => p.thumbUrl,
                orElse: () => 'assets/images/m_profile/m_black.png',
              );

    final created = st.post == null
        ? '09.17 17:47'
        : DateFormat('MM.dd HH:mm').format(st.post!.communityCreateDate.toLocal());

    final body = st.post?.communityDetail ?? '게시글내용';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: CommonAppBar(
            actions: [
              // 북마크 버튼 (본인 글이 아닌 경우)
              if (!isOwner) ...[
                IconButton(
                  icon: st.loadingBookmark
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          st.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: st.isBookmarked ? AppColors.primary : null,
                        ),
                  onPressed: st.loadingBookmark
                      ? null
                      : () {
                          ref.read(provider.notifier).toggleBookmark(ref);
                          ref
                              .read(communityChangedTickProvider.notifier)
                              .state++;
                        },
                ),
              ],

              // 삭제/수정 버튼 (본인 글인 경우)
              if (isOwner) ...[
                IconButton(
                  icon: Icon(
                    AppIcons.delete,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () async {
                    softdelete() async {
                      // 다이얼로그 닫기
                      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

                      // 실제 삭제 수행
                      final err = await ref.read(provider.notifier).softDelete(ref);
                      if (!context.mounted) return;
                      if (err != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                      } else {
                        if (!context.mounted) return;
                        // ★ 삭제 완료 후 호출 화면으로 돌아가면서 reload
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('게시글이 삭제되었습니다.')));
                        context.pop(true);
                      }
                    }

                    await showAppConfirmDialog(
                      context,
                      title: '삭제하시겠어요?',
                      message: '삭제하면 되돌릴 수 없어요.',
                      primaryText: '삭제',
                      secondaryText: '취소',
                      destructive: true,
                      onPrimary: softdelete,
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.mode_edit_outline_outlined),
                   onPressed: () async {
                  // 수정 페이지로 이동하고, 돌아올 때 true를 받으면 reload
                   final result = await context.push('/community-edit', 
                     extra: {
                       'id': widget.id,
                       'extra': widget.extra,
                     },
                   );
                
                   // 수정 완료 후 돌아온 경우 데이터 다시 불러오기
                   if (result == true && mounted) {
                     await ref.read(provider.notifier).loadInitial(ref);
                   }
                 },
                ),
                const SizedBox(width: 5),
              ],
            ],
          ),
          body: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 15, 24, 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const Divider(thickness: 2, color: AppColors.white),
                          _HeaderRow(
                            author: author,
                            createdAt: created,
                            authorImg: authorImg == ""
                                ? 'assets/images/m_profile/m_black.png'
                                : authorImg,
                          ),
                          const Divider(thickness: 2, color: AppColors.white),
                          _PostBody(body: body),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(thickness: 10, color: Color(0xFFEBEBEB)),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PlainHeaderDelegate(
                      height: 48,
                      child: Builder(
                        builder: (context) {
                          return _SortTabs(
                            onTap: (i) {
                              final ctrl = DefaultTabController.of(context);
                              ctrl.animateTo(i);

                              final ord = i == 0
                                  ? CommentOrder.latest
                                  : CommentOrder.popular;
                              ref.read(provider.notifier).refreshComments(ref, ord);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _pagedList(ref, st),
                    _pagedList(ref, st),
                  ],
                ),
              ),
              if (currentUid != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CommentWrite(
                    commentController: commentController,
                    submit: submit,
                    currentUid: currentUid,
                    detailVmProvider: provider,
                    focusNode: commentFocusNode,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- 헤더, 게시글, 탭 위젯 -----------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.author,
    required this.createdAt,
    required this.authorImg,
  });
  final String author;
  final String createdAt;
  final String authorImg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          SizedBox(
            height: 35,
            width: 35,
            child: Image.asset(authorImg),
          ),
          const SizedBox(width: 8),
          Text(author),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                createdAt,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(8),
      child: Text(body),
    );
  }
}

class _PlainHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PlainHeaderDelegate({required this.child, required this.height});
  final Widget child;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: SizedBox(height: height, child: child));
  }

  @override
  bool shouldRebuild(covariant _PlainHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}

class _SortTabs extends StatelessWidget {
  const _SortTabs({required this.onTap});
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final idx = controller.index;
        TextStyle style(bool selected) => TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.black : Colors.grey,
            );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(0),
                child: Text('최신순', style: style(idx == 0)),
              ),              
              const SizedBox(width: 8),
              const Text('|', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(1),
                child: Text('추천순', style: style(idx == 1)),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class AppIcons {
  AppIcons._();
  static const String _kFontFam = 'AppIcons';
  static const IconData delete = IconData(0xe900, fontFamily: _kFontFam);
}
