// 입력창
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/xss.dart';
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

    //금지어 적용하기위한 폼키
    final formKey = GlobalKey<FormState>();
    // 제출 공통 처리
    void trySubmit() {
      // 금지어/정화 검증(validator 트리거)
      if (!formKey.currentState!.validate()) return;
      // 통과 시 실제 submit
      submit();
      // 포커스 해제
      FocusScope.of(context).unfocus();
    }

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
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  controller: commentController,
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

                                  decoration: InputDecoration(
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
                                  onFieldSubmitted: (_) => submit,
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(25),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: trySubmit, // ← 검증 후 submit
                                child: const SizedBox(
                                  height: 46,
                                  width: 64,
                                  child: Center(
                                    child: Text(
                                      '확인',
                                      style: TextStyle(color: Colors.white),
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
