# Line 로그인

## 방식
`flutter_web_auth_2` → Supabase Edge Function (`line-auth`) → Supabase 세션

Supabase가 Line을 기본 OAuth 제공자로 지원하지 않아 Edge Function으로 직접 구현.

## 키 및 설정값

| 항목 | 값 |
|------|-----|
| Channel ID | `2009604360` |
| Channel Secret | 별도 보관 (Supabase secret: `LINE_CHANNEL_SECRET`) |

## 전체 인증 흐름

```
Flutter
  └─ FlutterWebAuth2.authenticate(Line OAuth URL)
       └─ Line 로그인 화면
            └─ Line이 Edge Function으로 리디렉션 (?code=...)
                 └─ Edge Function
                      ├─ Line 토큰 교환 (code → id_token)
                      ├─ Supabase 유저 생성/확인
                      ├─ Magic link 생성 (redirectTo: com.bebetap.app://login-callback)
                      └─ Supabase verify URL로 리디렉션
                           └─ Supabase가 com.bebetap.app://login-callback#access_token=...&refresh_token=... 으로 리디렉션
                                └─ FlutterWebAuth2가 캡처 → refresh_token 파싱
                                     └─ supabase.auth.setSession(refreshToken)
```

## Line Developers Console 설정
- **채널 유형**: LINE Login
- **앱 유형**: Native app + Web app
- **LINE Login 탭 → Callback URL**:
  ```
  https://wamqeqdxocnojvyrtelu.supabase.co/functions/v1/line-auth
  ```

## Supabase Edge Function (supabase/functions/line-auth/index.ts)

배포 명령:
```bash
supabase secrets set LINE_CHANNEL_ID=2009604360 LINE_CHANNEL_SECRET=<secret>
supabase functions deploy line-auth --no-verify-jwt
```

> `--no-verify-jwt` 필수: Line이 Authorization 헤더 없이 리디렉션하므로 JWT 검증 비활성화 필요.

## Flutter 코드 (auth_repository_impl.dart)

```dart
Future<void> signInWithLine() async {
  const lineChannelId = '2009604360';
  const edgeFunctionUrl =
      'https://wamqeqdxocnojvyrtelu.supabase.co/functions/v1/line-auth';

  final lineAuthUrl = Uri.https('access.line.me', '/oauth2/v2.1/authorize', {
    'response_type': 'code',
    'client_id': lineChannelId,
    'redirect_uri': edgeFunctionUrl,
    'state': DateTime.now().millisecondsSinceEpoch.toString(),
    'scope': 'openid profile email',
  }).toString();

  final result = await FlutterWebAuth2.authenticate(
    url: lineAuthUrl,
    callbackUrlScheme: 'com.bebetap.app',
  );

  final fragment = Uri.parse(result).fragment;
  final params = Map.fromEntries(
    fragment.split('&').map((e) {
      final idx = e.indexOf('=');
      return MapEntry(e.substring(0, idx), Uri.decodeComponent(e.substring(idx + 1)));
    }),
  );

  await _client.auth.setSession(params['refresh_token']!);
}
```

## 사용 패키지
- `flutter_web_auth_2: ^4.0.1`
