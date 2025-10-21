import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ja_chwi/domain/entities/comment.dart';
import 'package:ja_chwi/presentation/providers/block_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:ja_chwi/presentation/screens/community/widgets/app_confirm_dialog.dart';

Future<void> showCommentContextMenu({
  required BuildContext context,
  required WidgetRef ref,
  required LongPressStartDetails details,
  required String? meUid,
  required String targetUid,
  required String nickname,
  required String commentText,
  required DateTime createdAt,
  NotifierProvider<CommunityDetailVM, CommunityDetailState>? detailVmProvider,
  List<Comment>? comments,
  int? index,
  Future<void> Function()? onDelete,
}) async {
  final scaffold = ScaffoldMessenger.of(context);
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  final selected = await showMenu<String>(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(15),
    ),
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      Offset.zero & overlay.size,
    ),
    color: Colors.white,
    items: [
      if (meUid != targetUid) ...[
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Text('신고하기'),
              SizedBox(width: 50),
              Spacer(),
              Icon(Icons.notifications_none),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Text('차단하기'),
              Spacer(),
              Icon(Icons.do_not_disturb_on_outlined),
            ],
          ),
        ),
      ] else ...[
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Text('삭제하기'),
              Spacer(),
              Icon(Icons.delete_outline),
            ],
          ),
        ),
      ],
    ],
  );

  switch (selected) {
    case 'report':
      if (meUid == null) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        break;
      }
      if (!context.mounted) return;
      context.push(
        '/report',
        extra: {
          'targetUserId': targetUid,
          'targetUserName': nickname,
          'targetContent': commentText,
          'targetCreatedAt': createdAt,
        },
      );
      break;
    case 'block':
      if (meUid == null) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        break;
      }

      final ok = await showAppConfirmDialog(
        context,
        title: '$nickname 님을 차단할까요',
        message: '차단하면 이 사용자의 게시글과 댓글이 보이지 않음',
        primaryText: '확인',
        secondaryText: '취소',
        destructive: true,
      );

      if (ok == true) {
        final err = await ref.read(blockUserActionProvider)(
          myUid: meUid,
          targetUid: targetUid,
          reason: null,
        );
        if (err != null) {
          scaffold.showSnackBar(SnackBar(content: Text(err)));
        } else {
          scaffold.showSnackBar(
            const SnackBar(content: Text('차단 완료')),
          );
          ref.read(communityChangedTickProvider.notifier).state++;
          ref.invalidate(blockedUsersProvider);
        }
      }
      break;
    case 'delete':
      final shouldDelete = await showAppConfirmDialog(
        context,
        title: '댓글 삭제',
        message: '댓글을 삭제하시겠습니까?\n삭제된 댓글은 복구할 수 없습니다.',
        primaryText: '삭제',
        secondaryText: '취소',
      );

      if (shouldDelete == true) {
        try {
          if (onDelete != null) {
            await onDelete();
          } else if (detailVmProvider != null &&
              comments != null &&
              index != null) {
            await ref
                .read(detailVmProvider.notifier)
                .deleteComment(
                  ref,
                  comments[index].id,
                );
          }
          if (context.mounted) {
            scaffold.showSnackBar(
              const SnackBar(content: Text('댓글이 삭제되었습니다')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            scaffold.showSnackBar(
              SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
            );
          }
        }
      }
      break;
    case null:
      break;
  }
}
