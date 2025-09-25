import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ja_chwi/core/utils/xss.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_grid.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/profile_header.dart';
import 'package:ja_chwi/presentation/screens/profile/widgets/selected_preview.dart';
import 'package:ja_chwi/domain/entities/profile_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ja_chwi/presentation/providers/profile_providers.dart';
import 'package:go_router/go_router.dart';

/// 단계별 진행 상태 Provider
final stepProvider = StateProvider<int>((ref) => 0);

/// 닉네임 입력 위젯
class NicknameInput extends ConsumerStatefulWidget {
  final Future<void> Function(String)? onNext;

  const NicknameInput({super.key, this.onNext});

  @override
  ConsumerState<NicknameInput> createState() => _NicknameInputState();
}

class _NicknameInputState extends ConsumerState<NicknameInput> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  /// 현재 입력된 값 검증 + 다음 단계 콜백
  Future<bool> validateAndProceed() async {
    final input = _controller.text.trim();
    final sanitized = XssFilter.sanitize(input);

    if (sanitized.isEmpty) {
      setState(() => errorText = "닉네임을 입력해주세요");
      return false;
    }

    // 금지어 체크
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

/// Profile Flow Page
class ProfileFlowPage extends ConsumerStatefulWidget {
  const ProfileFlowPage({super.key});

  @override
  ConsumerState<ProfileFlowPage> createState() => _ProfileFlowPageState();
}

class _ProfileFlowPageState extends ConsumerState<ProfileFlowPage> {
  String? dongName;
  final GlobalKey<_NicknameInputState> nicknameKey =
      GlobalKey<_NicknameInputState>();

  @override
  void initState() {
    super.initState();
    fetchDongName();
  }

  // 닉네임 중복 체크 후 다음 단계
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

    ref.read(nicknameProvider.notifier).state = nickname;
    ref.read(stepProvider.notifier).state = 1;
  }

  // VWorld API를 통해 동명 가져오기
  Future<void> fetchDongName() async {
    final key = dotenv.env['VWORLD_API_KEY'];
    final lat = 37.5665;
    final lon = 126.9780;

    final url =
        'https://api.vworld.kr/req/address?service=address&request=getAddress&version=2.0&point=$lon,$lat&type=PARCEL&key=$key';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        dongName = json['response']?['result']?[0]?['text'] ?? '';
      });
    }
  }

  // Firebase 저장
  Future<void> saveProfile() async {
    final nickname = ref.read(nicknameProvider);
    final selectedImage = ref.read(selectedImageProvider);
    final userId = "exampleUserId"; // 실제 Firebase Auth UID 사용

    if (nickname != null && selectedImage != null && dongName != null) {
      final profile = Profile(
        nickname: nickname,
        imageFullUrl: selectedImage.fullUrl,
        dongName: dongName!,
        createDate: DateTime.now(),
      );

      await ref.read(profileRepositoryProvider).saveProfile(profile, userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필 저장 완료")),
      );
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
    context.push('/home');
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(stepProvider);

    return Scaffold(
      appBar: AppBar(
        //  title: const Text("Profile Flow"),
        leading: step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context); // 이전 화면으로 이동
                },
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: LinearProgressIndicator(
            value: (step + 1) / 3,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: 4,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              ProfileHeader(step: step),
              const SizedBox(height: 16),

              if (step == 0) NicknameInput(key: nicknameKey, onNext: onNicknameNext),
              if (step == 1) const ProfileGrid(),
              if (step == 2)
                Text(dongName != null
                    ? "현재 동명: $dongName"
                    : "동명 불러오는 중..."),

              const SizedBox(height: 16),
              const SelectedPreview(),
            ],
          ),
        ),
      ),

      /// ✅ step 별 버튼 처리
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            if (step == 0) {
              final valid = await nicknameKey.currentState?.validateAndProceed();
              if (valid != true) return;
            } else if (step == 1) {
              ref.read(stepProvider.notifier).state = 2;
            } else if (step == 2) {
              await onConfirm();
            }
          },
          style: ElevatedButton.styleFrom( 
            minimumSize: const Size.fromHeight(52), // 높이 56           
            elevation: 0, // 그림자 제거
            backgroundColor: Colors.transparent, // 배경 투명
            shadowColor: Colors.transparent, // 그림자색 제거
            side: const BorderSide(color: Colors.grey, width: 1), // 실선 테두리
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // 모서리 둥글게
            ),
          ),
          child: Text(
            step == 2 ? "저장" : "다음",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
