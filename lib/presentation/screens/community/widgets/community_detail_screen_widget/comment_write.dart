// 입력창
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/presentation/providers/user_profile_by_uid_provider.dart.dart';

class CommentWrite extends ConsumerWidget {
  const CommentWrite({
    super.key,
    required this.commentController,
    required this.submit,
    required this.currentUid,
  });
  final TextEditingController commentController;
  final VoidCallback submit;
  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //uid 기반 프로필정보 로드(유저정보,위치정보)
    final profileAv = ref.watch(profileByUidProvider(currentUid));
    final profileImg = profileAv.when(
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Image.asset('assets/images/m_profile/m_black.png'),
      data: (data) => Image.asset(data.thumbUrl),
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
              // 상단 그라데이션 (필요시 높이 조절)
              Container(
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.fromARGB(0, 255, 255, 255), Colors.white],
                  ),
                ),
              ),
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
                              child: TextFormField(
                                controller: commentController,
                                minLines: 1,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '댓글을 입력하세요',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 46,
                              width: 64,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: GestureDetector(
                                onTap: submit,
                                child: const Center(
                                  child: Text(
                                    '확인',
                                    style: TextStyle(color: Colors.white),
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
