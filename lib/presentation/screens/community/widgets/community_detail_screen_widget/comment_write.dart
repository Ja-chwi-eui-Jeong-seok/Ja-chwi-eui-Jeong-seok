// 입력창
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_detail_vm.dart';
import 'package:ja_chwi/presentation/screens/community/vm/community_list_vm.dart';
import 'package:ja_chwi/presentation/providers/reply_mode_provider.dart';

class CommentWrite extends ConsumerStatefulWidget {
  const CommentWrite({
    super.key,
    required this.commentController,
    required this.submit,
    required this.currentUid,
    this.detailVmProvider,
    this.focusNode,
  });
  final TextEditingController commentController;
  final Future<void> Function() submit;
  final String currentUid;
  final NotifierProvider<CommunityDetailVM, CommunityDetailState>?
  detailVmProvider;
  final FocusNode? focusNode;

  @override
  ConsumerState<CommentWrite> createState() => _CommentWriteState();
}

class _CommentWriteState extends ConsumerState<CommentWrite> {
  //금지어 적용하기위한 폼키
  final formKey = GlobalKey<FormState>();
  // 포커스 유지용
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // widget.focusNode가 null인 경우에만 dispose
    if (widget.focusNode == null) {
      _focus.dispose();
    }
    super.dispose();
  }

  void trySubmit() async {
    final sending = ref.read(commentSendingProvider);
    if (sending) return;

    final text = widget.commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 입력하세요')),
      );
      return;
    }
    if (!formKey.currentState!.validate()) return;

    ref.read(commentSendingProvider.notifier).state = true;
    try {
      // 답글 모드인지 확인
      final replyMode = ref.read(replyModeProvider);
      final replyData = ref.read(replyModeDataProvider);

      if (replyMode == ReplyMode.replying &&
          replyData != null &&
          widget.detailVmProvider != null) {
        // 답글 작성
        await ref
            .read(widget.detailVmProvider!.notifier)
            .addReply(
              ref,
              parentCommentId: replyData.parentCommentId,
              uid: widget.currentUid,
              text: text,
            );

        // 답글 모드 해제 및 컨트롤러 클리어
        ref.read(replyModeProvider.notifier).state = ReplyMode.none;
        ref.read(replyModeDataProvider.notifier).state = null;
        widget.commentController.clear(); // 답글 완료 후 컨트롤러 클리어
      } else {
        // 일반 댓글 작성
        await widget.submit();
      }

      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) {
        ref.read(commentSendingProvider.notifier).state = false;
      }
    }
    ref.read(communityChangedTickProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    final sending = ref.watch(commentSendingProvider);
    ref.watch(replyModeProvider);
    ref.watch(replyModeDataProvider);

    //uid 기반 프로필정보 로드(유저정보,위치정보)
    final profileAv = ref.watch(profileByUidProvider(widget.currentUid));
    final profileImg = profileAv.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, _) => Image.asset('assets/images/m_profile/m_black.png'),
      data: (data) {
        final url = data.thumbUrl;
        if (url.isEmpty) {
          return Image.asset('assets/images/m_profile/m_black.png');
        }
        if (url.startsWith('http')) return Image.network(url);
        return Image.asset(url);
      },
    );

    return Padding(
      // 키보드 높이만큼 올리기
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        elevation: 8,
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 그라데이션 (필요시 높이 조절) - 터치 통과
              IgnorePointer(
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.fromARGB(0, 255, 255, 255), Colors.white],
                    ),
                  ),
                ),
              ),

              // 답글 모드 표시
              // if (replyMode == ReplyMode.replying && replyData != null)
              //   Container(
              //     width: double.infinity,
              //     // margin: const EdgeInsets.only(bottom: 12),
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 12,
              //       vertical: 8,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Colors.blue[50],
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: Colors.blue[200]!),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(
              //           Icons.reply,
              //           size: 16,
              //           color: Colors.blue[600],
              //         ),
              //         const SizedBox(width: 8),
              //         Text(
              //           '${replyData.parentCommentNickname}님에게 답글',
              //           style: TextStyle(
              //             color: Colors.blue[600],
              //             fontWeight: FontWeight.w500,
              //             fontSize: 14,
              //           ),
              //         ),
              //         const Spacer(),
              //         GestureDetector(
              //           onTap: () {
              //             // 답글 모드 해제
              //             ref.read(replyModeProvider.notifier).state =
              //                 ReplyMode.none;
              //             ref.read(replyModeDataProvider.notifier).state = null;
              //             widget.commentController.clear();
              //           },
              //           child: Icon(
              //             Icons.close,
              //             size: 16,
              //             color: Colors.blue[600],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: profileImg,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  enabled: !sending,
                                  focusNode: _focus,
                                  controller: widget.commentController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }
                                    final r = XssFilter.secureInput(value);
                                    if (r['hasBannedWord'] == true) {
                                      final words = (r['matchedWords'] as List)
                                          .join(', ');
                                      return '금지어 : $words';
                                    }
                                    return null;
                                  },
                                  minLines: 1,
                                  maxLines: 6,
                                  maxLength: 50,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    hintText: '댓글을 입력하세요',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,

                                  onFieldSubmitted: (_) =>
                                      trySubmit(), // ← 실제 실행
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(25),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: sending
                                    ? null
                                    : trySubmit, // ← 검증 후 submit
                                child: SizedBox(
                                  height: 46,
                                  width: 64,
                                  child: Center(
                                    child: sending
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            '확인',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
