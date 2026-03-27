# BebeTap TODO

## 긴급 / 버그

- [ ] 이메일 회원가입 전체 플로우 실기기 테스트
  - 이메일 입력 → OTP 발송 → 비밀번호 설정 → OTP 코드 입력 → 아기 등록 화면 이동
  - 재시작 후 이메일+비밀번호 로그인 확인
  - 이미 가입된 이메일로 시도 시 로그인 링크 동작 확인
- [ ] 아기 정보 저장 테스트 (DB RLS 재귀 수정 후)
- [ ] 소셜 로그인 동작 확인 (Google, Kakao, Facebook, Line)

---

## 인증 / 로그인

- [ ] **Android Google 로그인**: `android/app/google-services.json` 추가 필요
- [ ] **Apple 로그인**: 구현 및 활성화 (`enabled = false` 상태)
- [ ] **네이버 로그인**: Edge Function 배포 + `signInWithNaver()` 구현
- [ ] 비밀번호 재설정 플로우 테스트 (`sendPasswordResetEmail`)

---

## 핵심 기능

- [ ] 홈 화면 수유/수면/기저귀 기록 저장 → DB 연동 확인
- [ ] 통계 화면 Day/Week/Month 데이터 정상 표시 확인
- [ ] 가족 생성 + 초대 코드 발급 + 합류 플로우 테스트
- [ ] 실시간 동기화 (`realtime_listener.dart`) 동작 확인

---

## 출시 준비

- [ ] iOS 홈 위젯 실기기 테스트 (WidgetKit)
- [ ] Android 홈 위젯 실기기 테스트 (Jetpack Glance)
- [ ] `flutter analyze` 경고/오류 정리
- [ ] 한국어/영어 ARB 번역 누락 항목 확인
- [ ] App Store / Play Store 메타데이터 준비

---

## 인프라 / Supabase

- [ ] `supabase/config.toml` 환경변수 `.env` 파일로 분리 (현재 secret 하드코딩)
- [ ] Supabase Storage 버킷 설정 (아기 프로필 사진 업로드용)
- [ ] Edge Function 배포 상태 확인 (`line-auth`, `naver-auth`)
