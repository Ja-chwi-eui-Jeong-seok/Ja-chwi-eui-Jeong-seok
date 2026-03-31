# 자취의 정석 (Ja-chwi-eui-Jeong-seok)

자취 생활을 보다 스마트하게!  
이 앱은 자취생을 위한 미션 기반 커뮤니티 앱으로, 다양한 기능을 통해 자취 생활을 효율적으로 관리하고, 커뮤니티와 소통할 수 있도록 돕습니다.

---

## 🧱 프로젝트 구조

### 📁 lib/

앱의 핵심 로직과 UI가 포함된 주요 디렉토리입니다.

- `core/`: 앱 설정, 상수, 예외 처리, 유틸리티
- `data/`: 데이터 소스, 모델, DTO, Repository 구현
- `domain/`: 도메인 모델, Repository 인터페이스, UseCase
- `presentation/`: UI 화면, 공통 위젯, 상태 관리
- `firebase_options.dart`: Firebase 설정
- `main.dart`: 앱 진입점

### 📁 assets/

이미지, 폰트, 환경 변수, JSON 데이터 등 리소스 파일이 포함되어 있습니다.

- `banned_words/`: 금칙어 목록 (`slang.csv`)
- `config/`: 환경 변수 및 JSON 설정
  - `env/setting.env`: 환경 변수
  - `json/`: 디바이스, 이미지, 모지 관련 JSON 데이터
- `fonts/`: 앱에서 사용하는 폰트 파일
- `icon/`: 앱 아이콘
- `images/`: 로그인, 아이콘, 프로필 이미지 등

---

## ✨ 주요 기능

- 미션 추가 및 관리
- AI 기반 채팅 기능
- 커뮤니티 및 즐겨찾기
- 사용자 인증 및 프로필 설정
- 가이드 제공
- 관리자 기능 및 신고 시스템

---

# 프로젝트 구조 (기능별/화면별 박스형 다이어그램)
```
┌───────────────────────┐
│         lib           │
│  (앱 소스코드)           │
└───────┬────────────--─┘
        ├── core                        # 앱의 핵심 설정, 상수, 유틸리티 등 공통 모듈
        │   ├── config                  # 앱 설정 관련
        │   │   ├── dio.dart            # 네트워크 통신용 Dio 설정
        │   │   ├── router               # 라우터 관련 설정
        │   │   │   ├── route_titles.dart # 화면별 라우터 타이틀 정의
        │   │   │   └── router.dart      # 앱 전체 라우팅 정의
        │   │   └── theme
        │   │       └── app_theme.dart   # 앱 전체 테마 정의 (색상, 폰트, 스타일)
        │   ├── constants               # 상수 정의
        │   │   ├── app_colors.dart      # 앱에서 사용하는 색상 정의
        │   │   ├── app_sizes.dart       # 앱 전역 사이즈 정의
        │   │   └── app_text_styles.dart # 텍스트 스타일 정의
        │   ├── error
        │   │   └── exceptions.dart      # 예외 처리 정의
        │   └── utils
        │       ├── level_calculator.dart # 레벨 계산 유틸
        │       ├── nickname_validator.dart # 닉네임 검증 유틸
        │       └── xss.dart              # XSS 방어 유틸
        ├── data                        # 데이터 소스, 모델, DTO, Repository 구현
        │   ├── common
        │   │   └── page_result.dart     # 페이징 결과 공통 모델
        │   ├── datasources              # 실제 데이터 접근(서버/DB) 모듈
        │   │   ├── ...                   # auth, community, mission 등 각 기능별 데이터 소스
        │   ├── dto                      # API와 주고받는 데이터 구조
        │   ├── models                   # 내부 데이터 모델 정의
        │   └── repositories             # Repository 구현체 (Domain에 정의된 Repository 구현)
        ├── domain                      # 앱의 핵심 비즈니스 로직
        │   ├── entities                 # 핵심 도메인 모델(Entity)
        │   ├── repositories             # Repository 인터페이스 정의
        │   └── usecases                 # 비즈니스 로직 단위(UseCase) 정의
        ├── firebase_options.dart        # Firebase 옵션 (자동 생성)
        ├── main.dart                    # 앱 진입점
        └── presentation                 # UI 관련 폴더
            ├── common                   # 공통 위젯, 유틸
            ├── device_info.dart         # 디바이스 정보 관련
            ├── providers                # Riverpod 상태 관리 Provider
            ├── screens                  # 화면 단위 폴더
            │   ├── add_mission          # 미션 추가 화면
            │   ├── admin                # 관리자 화면
            │   ├── ai_chat              # AI 채팅 화면
            │   ├── auth                 # 인증 관련 화면
            │   ├── block                # 차단 관련 화면
            │   ├── bookmark             # 즐겨찾기 화면
            │   ├── category             # 카테고리 화면
            │   ├── community            # 커뮤니티 화면
            │   ├── csv                  # CSV 관련 화면
            │   ├── guide                # 가이드 화면
            │   ├── help                 # 도움말 화면
            │   ├── home                 # 홈 화면
            │   ├── jachwi_screen.dart   # 자취 관련 화면
            │   ├── mission              # 미션 관련 화면
            │   ├── profile              # 프로필 관련 화면
            │   ├── report               # 신고 관련 화면
            │   ├── setting              # 설정 화면
            │   └── splash               # 스플래시 화면
            └── widgets                  # 공통 위젯

┌───────────────────────┐
│       assets          │
│ (이미지, 폰트, JSON)     │
└─────────┬─────────────┘
          ├── banned_words                 # 금지 단어 목록
          │   └── slang.csv                # 금칙어 CSV
          ├── config                       # 앱 설정 관련 파일
          │   ├── env
          │   │   └── setting.env          # 환경 변수 파일
          │   └── json                     # JSON 데이터
          │       ├── device_models.json   # 디바이스 모델 정보
          │       ├── images.json          # 이미지 정보
          │       ├── intro_monji.json     # 인트로 모지 데이터
          │       ├── monji_jump.json      # 모지 점프 관련 데이터
          │       └── sido.json            # 시/도 정보
          ├── fonts                        # 폰트 파일
          │   ├── GamjaFlower-Regular.ttf
          │   ├── icomoon.ttf
          │   └── Roboto-Medium.ttf
          ├── icon                         # 앱 아이콘
          │   └── icon.png
          └── images                       # 이미지 자원
              ├── google.png               # 구글 로그인 이미지
              ├── icons                    # 앱 아이콘 이미지
              │   ├── bell.png
              │   ├── chat.png
              │   ├── commu.png
              │   ├── home.png
              │   ├── mission.png
              │   ├── profile.png
              │   ├── reload.png
              │   ├── s_commu.png
              │   ├── s_home.png
              │   ├── s_mission.png
              │   └── s_profile.png
              ├── m_profile                #  프로필 관련 이미지
              │   ├── m_banana.png
              │   ├── m_black.png
              │   ├── m_green.png
              │   ├── m_night_blu.png
              │   ├── m_orange.png
              │   ├── m_pupple.png
              │   ├── m_red.png
              │   └── m_sky_blu.png
              └── profile                  # 기본 프로필 이미지
                  ├── banana.png
                  ├── black.png
                  ├── green.png
                  ├── hide.png             
                  ├── night_blu.png
                  ├── orange.png
                  ├── pupple.png
                  ├── red.png
                  ├── sky_blu.png
                  ├── sleep.png            
                  └── tung.png
```

---


## 📦 사용 중인 Flutter 패키지 요약

| 패키지 이름 | 기능 설명 | 버전 |
|-------------|------------|--------|
| Dart    |              | 3.9.2| 
| flutter | Flutter SDK | 3.35.5 |
| flutter_localizations | 다국어 지원 | sdk |
| cupertino_icons | iOS 스타일 아이콘 | ^1.0.8 |
| go_router | 라우팅 관리 | ^16.2.1 |
| firebase_core | Firebase 초기화 | ^4.1.0 |
| firebase_auth | Firebase 인증 | ^6.0.2 |
| firebase_database | 실시간 DB | ^12.0.1 |
| firebase_storage | 파일 저장소 | ^13.0.1 |
| firebase_analytics | 사용자 분석 | ^12.0.1 |
| firebase_messaging | 푸시 알림 | ^16.0.1 |
| firebase_crashlytics | 크래시 리포트 | ^5.0.1 |
| sentry_flutter | 오류 추적 | ^9.6.0 |
| flutter_image_compress | 이미지 압축 | ^2.4.0 |
| webview_flutter | 웹뷰 | ^4.3.1 |
| permission_handler | 권한 요청 | ^12.0.1 |
| geocoding | 주소 ↔ 좌표 변환 | ^4.0.0 |
| google_fonts | 구글 폰트 사용 | ^6.3.2 |
| intl | 날짜/숫자 국제화 | ^0.20.2 |
| timeago | 상대 시간 표현 | ^3.7.1 |
| logger | 로그 출력 | ^2.6.1 |
| json_annotation | JSON 직렬화 어노테이션 | ^4.9.0 |
| path_provider | 경로 접근 | ^2.1.5 |
| flutter_riverpod | 상태 관리 | ^2.6.1 |
| lottie | 애니메이션 | ^3.3.2 |
| cloud_firestore | Firebase Firestore | ^6.0.1 |
| google_sign_in | Google 로그인 | ^6.2.1 |
| sign_in_with_apple | Apple 로그인 | ^6.1.0 |
| percent_indicator | 퍼센트 UI 위젯 | ^4.2.5 |
| device_info_plus | 디바이스 정보 | ^12.1.0 |
| table_calendar | 캘린더 UI | ^3.1.3 |
| shared_preferences | 로컬 저장소 | ^2.2.2 |
| url_launcher | 외부 링크 열기 | ^6.3.0 |
| image_picker | 이미지 선택 | ^1.1.2 |
| http | HTTP 통신 | ^1.5.0 |
| dotenv | 환경 변수 관리 | ^4.2.0 |
| flutter_dotenv | .env 파일 로딩 | ^6.0.0 |
| csv | CSV 처리 | ^6.0.0 |
| cached_network_image | 네트워크 이미지 캐싱 | ^3.4.1 |
| timezone | 시간대 처리 | ^0.10.1 |
| google_generative_ai | Google AI API | ^0.4.7 |
| crypto | 암호화 유틸 | ^3.0.6 |

### 🧪 개발용 패키지

| 패키지 이름 | 기능 설명 | 버전 |
|-------------|------------|--------|
| flutter_test | 테스트 프레임워크 | sdk |
| flutter_launcher_icons | 앱 아이콘 생성 | ^0.13.1 |
| flutter_lints | 린트 규칙 | ^5.0.0 |
| build_runner | 코드 생성 자동화 | ^2.8.0 |
| json_serializable | JSON 직렬화 생성기 | ^6.11.1 |
| mockito | 테스트용 목 객체 | ^5.5.1 |

---

## 👥 개발자 정보

| 이름 | 역할 |
|------|------|
| 이영상 | 리더 / 커뮤니티 구현, firebase 연동 |
| 임초희 | 부리더 / 프로필 구현 , 관리자 기능 추가 구현|
| 이상록 | 팀원 / 로그인 및 main 구현, 디자이너 소통 및 레퍼런스 작업 |
| 동세진 | 팀원 / 미션 구현 및 오류 확인, 데이터 체크  |
| 이한효 | UI/UX 디자이너 | 
