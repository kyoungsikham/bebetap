import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인증 저장소.
/// 각 소셜 로그인 메서드는 플랫폼 SDK → Supabase 세션 획득 순서로 동작.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // ── Google ────────────────────────────────────────────────────────────────
  /// 네이티브 Google Sign-In → Supabase signInWithIdToken.
  /// TODO: Google Cloud Console에서 iOS/Android 클라이언트 ID를 발급받아
  ///       아래 serverClientId를 채워야 합니다.
  Future<void> signInWithGoogle() async {
    const webClientId =
        '343593600698-ji8aqb4t29ecmr7i6hea3st5bhfejpre.apps.googleusercontent.com';
    final googleSignIn = GoogleSignIn(serverClientId: webClientId);
    final account = await googleSignIn.signIn();
    if (account == null) return; // 사용자 취소

    final auth = await account.authentication;
    if (auth.idToken == null) throw Exception('Google ID 토큰을 받지 못했습니다');

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: auth.idToken!,
      accessToken: auth.accessToken,
    );
  }

  // ── Apple ─────────────────────────────────────────────────────────────────
  /// 네이티브 Apple Sign-In → Supabase signInWithIdToken.
  /// iOS 13+ 필수. Android는 웹 기반으로 동작.
  Future<void> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    if (credential.identityToken == null) {
      throw Exception('Apple ID 토큰을 받지 못했습니다');
    }
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: credential.identityToken!,
    );
  }

  // ── Kakao ─────────────────────────────────────────────────────────────────
  /// 네이티브 Kakao SDK → Supabase signInWithIdToken.
  /// account_email 스코프 없이 openid + profile_nickname 만 요청.
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

  // ── Naver ─────────────────────────────────────────────────────────────────
  /// 네이티브 Naver SDK → Supabase Edge Function으로 토큰 교환.
  /// TODO: Naver Developers에서 앱 등록 후
  ///       lib/core/config/app_config.dart에 clientId/clientSecret 추가.
  ///       supabase/functions/naver-auth Edge Function 배포 필요.
  Future<void> signInWithNaver() async {
    final result = await FlutterNaverLogin.logIn();
    if (result.status != NaverLoginStatus.loggedIn) {
      throw Exception('네이버 로그인이 취소되었습니다');
    }
    // TODO: Edge Function으로 토큰 교환
    // final tokenResult = await FlutterNaverLogin.currentAccessToken;
    // final response = await _client.functions.invoke(
    //   'naver-auth',
    //   body: {'access_token': tokenResult.accessToken},
    // );
    // await _client.auth.setSession(response.data['access_token']);
    throw UnimplementedError('네이버 로그인은 Edge Function 배포 후 활성화됩니다');
  }

  // ── Facebook ──────────────────────────────────────────────────────────────
  /// Supabase OAuth (브라우저 리디렉션).
  /// TODO: Supabase 대시보드 → Auth → Providers → Facebook 활성화 필요.
  Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: 'com.bebetap.app://login-callback',
    );
  }

  // ── Line ──────────────────────────────────────────────────────────────────
  /// flutter_web_auth_2로 Line OAuth → Edge Function → Supabase 세션.
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

    // 인앱 브라우저로 Line 로그인 → com.bebetap.app://login-callback#tokens 캡처
    final result = await FlutterWebAuth2.authenticate(
      url: lineAuthUrl,
      callbackUrlScheme: 'com.bebetap.app',
    );

    // URL 프래그먼트에서 refresh_token 파싱
    final fragment = Uri.parse(result).fragment;
    if (fragment.isEmpty) throw Exception('Line 로그인 응답에 토큰이 없습니다');

    final params = Map.fromEntries(
      fragment.split('&').map((e) {
        final idx = e.indexOf('=');
        return MapEntry(e.substring(0, idx), Uri.decodeComponent(e.substring(idx + 1)));
      }),
    );

    final refreshToken = params['refresh_token'];
    if (refreshToken == null) throw Exception('refresh_token을 받지 못했습니다');

    await _client.auth.setSession(refreshToken);
  }

  // ── Email ─────────────────────────────────────────────────────────────────
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.bebetap.app://login-callback',
    );
  }

  /// 이메일이 이미 가입되어 있는지 확인 (DB RPC 호출)
  Future<bool> checkEmailExists(String email) async {
    final result = await _client.rpc('check_email_exists', params: {'check_email': email});
    return result as bool;
  }

  Future<void> sendEmailOtp(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  Future<void> verifyEmailOtp(String email, String token) async {
    await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> setPassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> signOut() => _client.auth.signOut();
}
