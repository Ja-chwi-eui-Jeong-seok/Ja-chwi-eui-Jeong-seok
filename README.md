# ja_chwi

자취의 정석

## 특이사항

1.클린아키텍쳐 구조로 쉘스클립트 실행하여 프로젝트 폴더 구조 생성

- generate_layered_structure.sh
  2.tree를 설치해서 프로젝트 파일 구조를 그대로 받아옴
  -(명령어) tree lib assets -L 4

## 프로젝트 구조

lib
├── core
│ ├── config
│ │ ├── dio.dart
│ │ └── router
│ │ ├── route_titles.dart
│ │ └── router.dart
│ └── error
│ └── exceptions.dart
├── data
│ ├── datasources
│ │ ├── image_datasource.dart
│ │ └── jachwi_datasource.dart
│ ├── models
│ │ ├── image_model.dart
│ │ └── jachwi_model.dart
│ └── repositories
│ ├── image_repository_impl.dart
│ └── jachwi_repository_impl.dart
├── domain
│ ├── entities
│ │ ├── image_entity.dart
│ │ └── jachwi.dart
│ ├── repositories
│ │ ├── image_repository.dart
│ │ └── jachwi_repository.dart
│ └── usecases
│ ├── get_images_usecase.dart
│ └── get_jachwi_usecase.dart
├── firebase_options.dart
├── main.dart
└── presentation
├── common
│ └── app_bar_titles.dart
├── providers
│ ├── image_provider.dart
│ └── jachwi_provider.dart
├── screens
│ ├── admin
│ │ └── admin_screen.dart
│ ├── auth
│ │ ├── character_create_screen.dart
│ │ └── login_screen.dart
│ ├── community
│ │ ├── community_create_screen.dart
│ │ ├── community_detail_screen.dart
│ │ └── community_screen.dart
│ ├── home
│ │ └── home_screen.dart
│ ├── jachwi_screen.dart
│ ├── mission
│ │ ├── mission_achievers_screen.dart
│ │ ├── mission_create_screen.dart
│ │ ├── mission_edit_screen.dart
│ │ ├── mission_saved_list_screen.dart
│ │ └── mission_screen.dart
│ ├── profile
│ │ ├── back
│ │ ├── profile_screen.dart
│ │ └── widgets
│ └── report
│ ├── report_detail_screen.dart
│ ├── report_screen.dart
│ └── widgets
└── widgets
└── jachwi_widget.dart
assets
├── config
│ └── json
│ ├── images.json
│ └── monji_jump.json
└── images
├── m_profile
│ ├── m_banana.png
│ ├── m_black.png
│ ├── m_night_blu.png
│ ├── m_orange.png
│ ├── m_rainbow.png
│ ├── m_red.png
│ ├── m_sky_blu.png
│ └── m_white.png
└── profile
├── banana.png
├── black.png
├── night_blu.png
├── orange.png
├── rainbow.png
├── red.png
├── sky_blu.png
└── white.png

## 프로필 페이지

### 참고

1.아이콘 조회
https://fonts.google.com/icons?icon.query=account+se&icon.size=24&icon.color=%23e3e3e3

bottom
home
Assignment
groups
account circle

## 로그인페이지

UI (LoginScreen + LoginButton)
↓
UseCase (SignInWithGoogleUseCase, SignInWithAppleUseCase)
↓
Repository (AuthRepositoryImpl)
↓
DataSource (AuthRemoteDataSourceImpl)
↓
Firebase (Auth + Firestore)
