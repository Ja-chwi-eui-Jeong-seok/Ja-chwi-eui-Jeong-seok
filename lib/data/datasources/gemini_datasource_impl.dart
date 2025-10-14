import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_datasource.dart';

class GeminiDataSourceImpl implements GeminiDataSource {
  final GenerativeModel _model;

  // 생성자에서 Gemini 모델을 초기화

  GeminiDataSourceImpl(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        systemInstruction: Content.text(
          '''당신은 자취생을 위한 친근한 자취 5년차 집먼지 AI 어시스턴트입니다. 
        

주요 역할:
- 요리/레시피 추천 (간단하고 경제적)
- 청소/정리 팁 (효율적이고 실용적)
- 예산 관리 조언 (절약 중심)
- 생활 꿀팁 (자취생 맞춤)

답변 스타일:
- 친근하고 따뜻한 톤
- 구체적이고 실행 가능한 조언
- 자취생의 상황을 이해하고 공감
- 이모지 적절히 사용
- 짧고 간결하게

집먼지 말투로 답변해주세요.''',
        ),
        generationConfig: GenerationConfig(
          temperature: 0.3,
          topP: 0.9,
        ),
        safetySettings: [
          SafetySetting(
            HarmCategory.harassment,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.hateSpeech,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.medium,
          ),
        ],
      );

  @override
  Future<String> sendMessage(
    String message,
    List<Map<String, String>> history,
  ) async {
    try {
      // 대화 히스토리를 Content 객체로 변환
      final List<Content> contents = [];

      // 이전 대화 히스토리 추가
      for (final msg in history) {
        if (msg['role'] == 'user') {
          contents.add(Content.text(msg['content']!));
        } else if (msg['role'] == 'assistant') {
          contents.add(Content.model([TextPart(msg['content']!)]));
        }
      }

      // 현재 메시지 추가
      contents.add(Content.text(message));

      // Gemini API 호출
      final response = await _model.generateContent(contents);

      return response.text ?? '죄송합니다. 응답을 생성할 수 없습니다.';
    } catch (e) {
      throw Exception('메시지 전송 실패: $e');
    }
  }

  @override
  Future<String> generateRecipe(
    List<String> ingredients,
    List<Map<String, String>> history,
  ) async {
    try {
      // 재료 기반 레시피 생성 프롬프트
      final prompt =
          '''
사용자가 말한 내용: ${ingredients.join(', ')}

위 내용을 바탕으로 자취생 맞춤 레시피를 추천해주세요.
재료가 명확하지 않다면 추측해서 제안해주세요.

조건:
- 30분 이내 조리 가능
- 추가 재료 최소화 (기본 조미료만 사용)
- 난이도: 초보자도 가능
- 1-2인분 기준
- 경제적이고 영양가 있는 요리

레시피 형식:
🍳 [요리명]
⏰ 조리시간: XX분
🥘 재료: [필요한 재료]
👨‍🍳 조리법:
1. ...
2. ...
3. ...

💡 꿀팁: [추가 조언]
''';

      // 대화 히스토리와 함께 전송
      final response = await sendMessage(prompt, history);
      return response;
    } catch (e) {
      throw Exception('레시피 생성 실패: $e');
    }
  }

  @override
  Future<String> generateGreeting() async {
    try {
      final prompt = '''
안녕하세요! 자취생활 도우미 AI입니다 😊

어떤 도움이 필요하신가요? 아래 선택지 중 하나를 선택하거나 직접 질문해주세요!

🍳 요리/레시피 추천
🧹 청소/정리 팁  
💰 예산 관리 조언
🏠 생활 꿀팁
📝 직접 질문하기

언제든지 편하게 말씀해주세요! 자취생활을 더 편하고 즐겁게 만들어드릴게요 ✨
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? prompt; // 기본 인삿말 반환
    } catch (e) {
      // API 호출 실패 시 기본 인삿말 반환
      return '''
안녕하세요! 자취생활 도우미 AI입니다 😊

어떤 도움이 필요하신가요? 아래 선택지 중 하나를 선택하거나 직접 질문해주세요!

🍳 요리/레시피 추천
🧹 청소/정리 팁  
💰 예산 관리 조언
🏠 생활 꿀팁
📝 직접 질문하기

언제든지 편하게 말씀해주세요! 자취생활을 더 편하고 즐겁게 만들어드릴게요 ✨
''';
    }
  }
}
