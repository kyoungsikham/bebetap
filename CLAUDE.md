# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                  # 앱 실행
flutter build apk            # Android 빌드
flutter build ios            # iOS 빌드
flutter analyze              # 정적 분석 (lint)
flutter test                 # 전체 테스트
flutter test test/foo_test.dart  # 단일 테스트 실행
flutter pub get              # 의존성 설치
flutter pub add <package>    # 패키지 추가
```

### Supabase
```bash
supabase start               # 로컬 개발 스택 시작 (Docker 필요)
supabase stop                # 로컬 스택 중지
supabase status              # 로컬 URL / API 키 확인
supabase db diff             # 스키마 변경 감지
supabase db push             # 마이그레이션을 클라우드에 적용
supabase migration new <name>  # 새 마이그레이션 파일 생성
```

## Architecture

### Supabase 연결
- **클라우드 프로젝트:** `wamqeqdxocnojvyrtelu` (Singapore 리전)
- **URL / anon key:** `lib/main.dart`의 `Supabase.initialize()` 에 하드코딩
- 앱 전역에서 `supabase` 전역 변수(`Supabase.instance.client`)로 클라이언트에 접근

### 로컬 개발
- `supabase/config.toml`에 로컬 포트 구성 (API: 54321, DB: 54322, Studio: 54323)
- 로컬 사용 시 `main.dart`의 URL을 `http://127.0.0.1:54321`로 교체 (Android 에뮬레이터는 `http://10.0.2.2:54321`)
- 마이그레이션 파일은 `supabase/migrations/`에 위치

### 플랫폼
- 타겟: iOS, Android
- Material 3 디자인 시스템 사용

---

## 작업 규칙

### 메모리 자동 업데이트
- 인증/로그인 관련 파일(`login_screen.dart`, `email_auth_screen.dart`, `auth_repository_impl.dart`, `app_router.dart`) 또는 Supabase 설정(`config.toml`, `migrations/`)을 수정할 때마다 반드시 아래 파일을 업데이트한다:
  - `~/.claude/projects/-Users-ham-study-bebetap/memory/project_dev_status.md`
- TODO 항목이 완료되거나 새 작업이 생기면 `TODO.md`도 함께 갱신한다.
