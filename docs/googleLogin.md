# Google 로그인

## 방식
네이티브 Google Sign-In SDK → Supabase `signInWithIdToken`

## 키 및 설정값

| 항목 | 값 |
|------|-----|
| Web Client ID | `343593600698-ji8aqb4t29ecmr7i6hea3st5bhfejpre.apps.googleusercontent.com` |
| iOS Client ID | `343593600698-6l0k3r63ms3u97shfqjpv9gkl2s1kcvt.apps.googleusercontent.com` |
| Android Client ID | `343593600698-74emfmv35b83tn68sap3k4h0jt1ua2jj.apps.googleusercontent.com` |

## Supabase 설정 (config.toml)

```toml
[auth.external.google]
enabled = true
client_id = "343593600698-ji8aqb4t29ecmr7i6hea3st5bhfejpre.apps.googleusercontent.com"
secret = "env(SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET)"
skip_nonce_check = true
```

## iOS 설정 (Info.plist)

```xml
<key>GIDClientID</key>
<string>343593600698-6l0k3r63ms3u97shfqjpv9gkl2s1kcvt.apps.googleusercontent.com</string>
<key>GIDServerClientID</key>
<string>343593600698-ji8aqb4t29ecmr7i6hea3st5bhfejpre.apps.googleusercontent.com</string>
<!-- REVERSED_CLIENT_ID URL 스킴 -->
<key>CFBundleURLSchemes</key>
<array>
  <string>com.googleusercontent.apps.343593600698-6l0k3r63ms3u97shfqjpv9gkl2s1kcvt</string>
</array>
```

## Flutter 코드 (auth_repository_impl.dart)

```dart
Future<void> signInWithGoogle() async {
  const webClientId =
      '343593600698-ji8aqb4t29ecmr7i6hea3st5bhfejpre.apps.googleusercontent.com';
  final googleSignIn = GoogleSignIn(serverClientId: webClientId);
  final account = await googleSignIn.signIn();
  if (account == null) return;

  final auth = await account.authentication;
  await _client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: auth.idToken!,
    accessToken: auth.accessToken,
  );
}
```

## 사용 패키지
- `google_sign_in: ^6.2.2`
