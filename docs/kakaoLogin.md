# 카카오 로그인

## 방식
네이티브 Kakao Flutter SDK → Supabase `signInWithIdToken`

## 키 및 설정값

| 항목 | 값 |
|------|-----|
| Native App Key | `3b9088a9581a023f815855a1cc2c96f5` |
| REST API Key | `985bdf3b032b470819552366dbcdc519` (Supabase에 사용 안 함) |
| Admin Key | 별도 보관 |

> **주의:** Supabase `client_id`는 반드시 **Native App Key**를 써야 함.
> 네이티브 SDK가 발급하는 ID 토큰의 `aud` 클레임이 Native App Key 값이기 때문.
> REST API Key로 설정하면 "Unacceptable audience" 오류 발생.

## Supabase 설정 (config.toml)

```toml
[auth.external.kakao]
enabled = true
client_id = "3b9088a9581a023f815855a1cc2c96f5"   # Native App Key
secret = "env(SUPABASE_AUTH_EXTERNAL_KAKAO_SECRET)"
skip_nonce_check = true   # 모바일 네이티브 로그인 필수
```

## Kakao Developers 설정
- **플랫폼 → iOS**: Bundle ID `com.bebetap.app` 등록
- **플랫폼 → Android**: 패키지명 + 키 해시 등록
- **카카오 로그인 활성화**: ON
- **OpenID Connect 활성화**: ON (id_token 발급에 필요)
- **동의항목 스코프**: `openid`, `profile_nickname`

## main.dart 초기화

```dart
KakaoSdk.init(nativeAppKey: '3b9088a9581a023f815855a1cc2c96f5');
```

## Flutter 코드 (auth_repository_impl.dart)

```dart
Future<void> signInWithKakao() async {
  OAuthToken token;
  if (await isKakaoTalkInstalled()) {
    token = await UserApi.instance.loginWithKakaoTalk();
  } else {
    token = await UserApi.instance.loginWithKakaoAccount();
  }

  if (token.idToken == null) throw Exception('카카오 ID 토큰을 받지 못했습니다');

  await _client.auth.signInWithIdToken(
    provider: OAuthProvider.kakao,
    idToken: token.idToken!,
    accessToken: token.accessToken,
  );
}
```

## 사용 패키지
- `kakao_flutter_sdk_user: ^1.9.7`
