# Facebook 로그인

## 방식
Supabase `signInWithOAuth` (브라우저 리디렉션 방식)

## 키 및 설정값

| 항목 | 값 |
|------|-----|
| App ID | `1639489033755567` |
| App Secret | 별도 보관 (`SUPABASE_AUTH_EXTERNAL_FACEBOOK_SECRET`) |

## Supabase 설정 (config.toml)

```toml
[auth.external.facebook]
enabled = true
client_id = "1639489033755567"
secret = "env(SUPABASE_AUTH_EXTERNAL_FACEBOOK_SECRET)"
```

```toml
# 앱 딥링크 허용
additional_redirect_urls = ["https://127.0.0.1:3000", "com.bebetap.app://login-callback"]
```

## Facebook Developers 설정
- **Facebook 로그인 → 설정 → 유효한 OAuth 리디렉션 URI**:
  ```
  https://wamqeqdxocnojvyrtelu.supabase.co/auth/v1/callback
  ```
- **권한 및 기능**: `email` 추가 (상태: 테스트 준비 완료)
- **클라이언트 OAuth 로그인**: ON
- **웹 OAuth 로그인**: ON

## Flutter 코드 (auth_repository_impl.dart)

```dart
Future<void> signInWithFacebook() async {
  await _client.auth.signInWithOAuth(
    OAuthProvider.facebook,
    redirectTo: 'com.bebetap.app://login-callback',
  );
}
```

## 참고
- 앱이 개발 모드일 때 "Sorry, something went wrong" 메시지가 표시될 수 있으나 로그인은 정상 동작함
- 앱 심사 후 Live 모드로 전환 시 해결됨

## 사용 패키지
- `flutter_facebook_auth: ^7.1.1` (설치됨, 직접 사용하지 않음 — Supabase OAuth 방식 사용)
