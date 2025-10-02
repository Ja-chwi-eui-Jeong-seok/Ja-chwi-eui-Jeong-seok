import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_grid.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_header.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_flow_appbar.dart';
import 'package:go_router/go_router.dart';

final stepProvider = StateProvider<int>((ref) => 0);

class NicknameInput extends ConsumerStatefulWidget {
  final Future<void> Function(String)? onNext;
  const NicknameInput({super.key, this.onNext});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  Future<bool> validateAndProceed() async {
    final input = _controller.text.trim();
    final sanitized = XssFilter.sanitize(input);

    if (sanitized.isEmpty) {
      setState(() => errorText = "닉네임을 입력해주세요");
      return false;
    }

    final bannedResult = XssFilter.secureInput(sanitized);
    if (bannedResult['hasBannedWord'] == true) {
      setState(() => errorText =
          "사용할 수 없는 단어가 포함되어 있습니다: ${bannedResult['matchedWords'].join(', ')}");
      return false;
    }

    setState(() => errorText = null);

    if (widget.onNext != null) {
      await widget.onNext!(sanitized);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedImage != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  selectedImage.thumbUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '집먼지의 이름을 \n 만들어 주세요..', 
                 style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'gamjaflower', // ✅ pubspec.yaml에 등록한 폰트 이름
                ),
                
               // style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                // style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //   color: Colors.black,
                //   fontSize: 40,
                //   fontWeight: FontWeight.w900,)
              ),
            ],
          ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
          child: Text(
            '닉네임',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "집먼지의 이름을 지어주세요",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey, width: 3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.blue, width: 3),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class ProfileFlowPage extends ConsumerStatefulWidget {
  final String uid;
  const ProfileFlowPage({super.key, required this.uid, Map<String, dynamic>? extra});

  @override
  ConsumerState<ProfileFlowPage> createState() => _ProfileFlowPageState();
}

class _ProfileFlowPageState extends ConsumerState<ProfileFlowPage> {
  String? dongName;
  String? selectedNickname;
  List<Map<String, String>> dongList = [];
  final GlobalKey<_NicknameInputState> nicknameKey =
      GlobalKey<_NicknameInputState>();

  @override
  void initState() {
    super.initState();
    loadDongList();
  }

  Future<void> loadDongList() async {
    final jsonStr = await rootBundle.loadString('assets/config/json/sido.json');
    final List<dynamic> jsonData = json.decode(jsonStr);
    setState(() {
      dongList = jsonData
          .map((e) => {"sido": e['sido'] as String, "sigun": e['sigun'] as String})
          .toList();
    });
  }

  Future<void> onNicknameNext(String nickname) async {
    final isDuplicate =
        await ref.read(profileRepositoryProvider).isNicknameDuplicate(nickname);

    if (isDuplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("중복된 닉네임입니다")),
      );
      return;
    }

    if (nickname.length < 2 || nickname.length > 8) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임은 2자 이상 8자 이하로 입력해주세요")),
      );
      return;
    }

    setState(() {
      selectedNickname = nickname;
    });
    ref.read(nicknameProvider.notifier).state = nickname;
    ref.read(stepProvider.notifier).state = 2;
  }

  Future<void> saveProfile() async {
    final nickname = ref.read(nicknameProvider);
    final selectedImage = ref.read(selectedImageProvider);
    final userId = widget.uid;

    if (nickname != null && selectedImage != null && dongName != null) {
      final profile = Profile(
        nickname: nickname,
        imageFullUrl: selectedImage.fullUrl,
        thumbUrl: selectedImage.thumbUrl,
        color: selectedImage.color,
        dongName: dongName!,
        createDate: DateTime.now(),
      );

      await ref.read(profileRepositoryProvider).saveProfile(profile, userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필 저장 완료")),
      );
      await Future.delayed(const Duration(seconds: 1));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 선택해주세요")),
      );
    }
  }

  Future<void> onConfirm() async {
    await saveProfile();

    if (!mounted) return;

    final selectedImage = ref.read(selectedImageProvider);
    final nickname = ref.read(nicknameProvider);

    context.push(
      '/guide',
      extra: {
        'uid': widget.uid,
        'nickname': nickname,
        'thumbUrl': selectedImage?.thumbUrl,
        'imageFullUrl': selectedImage?.fullUrl,
        'color': selectedImage?.color,
        'dongName': dongName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(stepProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    return Scaffold(
      appBar: ProfileFlowAppBar(step: step),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (step == 0) ProfileHeader(step: step),
              const SizedBox(height: 16),
              if (step == 0) ...[
                const Text(
                  "캐릭터 선택",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const ProfileGrid(),
              ],
              if (step == 1)
                NicknameInput(key: nicknameKey, onNext: onNicknameNext),
              if (step == 2) ...[
                if (selectedImage != null && selectedNickname != null)
                  Column(
                    children: [
                      Image.asset(selectedImage.thumbUrl, width: 60, height: 60),
                      const SizedBox(width: 8),
                      Text(
                        selectedNickname!+'의 집은 \n 어디인가요? ',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'gamjaflower', // ✅ pubspec.yaml에 등록한 폰트 이름
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (dongList.isNotEmpty)
                Center(
                    child: DropdownMenu<String>(
                    initialSelection: dongName,                    
                    label: const Text("동 선택"),
                    dropdownMenuEntries: dongList
                        .map((e) => DropdownMenuEntry(
                            value: e['sigun']!, label: "${e['sido']} ${e['sigun']}"))
                        .toList(),
                    onSelected: (value) {
                      setState(() {
                        dongName = value;
                      });
                    },
                  ),
                )
        
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            if (step == 0) {
              if (selectedImage == null) return;
              ref.read(stepProvider.notifier).state = 1;
            } else if (step == 1) {
              final valid = await nicknameKey.currentState?.validateAndProceed();
              if (valid != true) return;
            } else if (step == 2) {
              if (dongName == null) return;
              await onConfirm();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black, // 글자/아이콘 색
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),   side: const BorderSide(
      color: Colors.black, // 테두리 색
      width: 1, // 테두리 두께
    ),
          ),
          child: Text(
            step == 2 ? "완료" : "다음",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
