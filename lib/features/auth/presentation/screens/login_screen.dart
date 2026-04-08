import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/auth_repository_impl.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  bool _obscurePassword = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_loading) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
    } on AuthException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.invalidEmailPassword)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.networkError)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showResetDialog() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.passwordReset),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: context.l10n.emailAddressLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.send),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(ctrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.resetEmailSent)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.sendFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _runSocial(Future<void> Function() fn) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.loginFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 소셜 로그인: credential 획득 → Supabase 로그인.
  /// 계정 연결은 Supabase가 동일 이메일 자동 처리.
  Future<void> _socialSignInWithCheck({
    required Future<SocialCredential?> Function() getCredential,
    required Future<void> Function(SocialCredential) completeSignIn,
    required String providerName,
  }) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final credential = await getCredential();
      if (credential == null) return; // 사용자 취소
      await completeSignIn(credential);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.loginFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(authRepositoryProvider);

    // 인증 후 babies 로딩 중이면 스피너 유지 (로그인 화면에 머무르는 동안)
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn = authAsync.valueOrNull?.session != null;
    final babiesAsync = ref.watch(babiesProvider);
    final showPostLoginLoading = isLoggedIn && !babiesAsync.hasValue;
    final isLoading = _loading || showPostLoginLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.huge),

              // 로고 + 타이틀
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.child_care,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('BebeTap', style: AppTypography.displayLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.loginSubtitle,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 이메일 입력
              _buildTextField(
                controller: _emailCtrl,
                hint: context.l10n.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.sm),

              // 비밀번호 입력
              _buildTextField(
                controller: _passwordCtrl,
                hint: context.l10n.password,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.onSurfaceMuted,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              // 비밀번호 찾기 + 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _showResetDialog,
                    child: Text(
                      context.l10n.forgotPassword,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.onSurfaceMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.emailAuth),
                    child: Text(
                      context.l10n.signupWithEmail,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // 로그인 버튼
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : _signInWithEmail,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.l10n.login,
                          style: AppTypography.labelLarge
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 구분선
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      context.l10n.orSocialLogin,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.onSurfaceMuted),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              if (!isLoading) ...[
                _SocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: context.l10n.continueWithGoogle,
                  onTap: () => _socialSignInWithCheck(
                    getCredential: repo.getGoogleCredential,
                    completeSignIn: repo.completeGoogleSignIn,
                    providerName: 'Google',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SocialLoginButton(
                  icon: Icons.chat_bubble,
                  label: context.l10n.continueWithKakao,
                  color: const Color(0xFFFEE500),
                  textColor: AppColors.onSurface,
                  onTap: () => _socialSignInWithCheck(
                    getCredential: repo.getKakaoCredential,
                    completeSignIn: repo.completeKakaoSignIn,
                    providerName: '카카오',
                  ),
                ),
                // const SizedBox(height: AppSpacing.sm),
                // _SocialLoginButton(
                //   icon: Icons.apple,
                //   label: 'Apple로 계속하기',
                //   onTap: () => _runSocial(repo.signInWithApple),
                // ),
                const SizedBox(height: AppSpacing.sm),
                _SocialLoginButton(
                  icon: Icons.facebook,
                  label: context.l10n.continueWithFacebook,
                  color: const Color(0xFF1877F2),
                  onTap: () => _runSocial(repo.signInWithFacebook),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SocialLoginButton(
                  icon: Icons.chat,
                  label: context.l10n.continueWithLine,
                  color: const Color(0xFF06C755),
                  onTap: () => _runSocial(repo.signInWithLine),
                ),
                // const SizedBox(height: AppSpacing.sm),
                // _SocialLoginButton(
                //   icon: Icons.eco,
                //   label: '네이버로 계속하기',
                //   color: const Color(0xFF03C75A),
                //   onTap: () => _runSocial(repo.signInWithNaver),
                // ),
              ],

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceMuted),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.surfaceVariant;
    final fg = textColor ?? (color != null ? Colors.white : AppColors.onSurface);

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: color == null
                ? const BorderSide(color: AppColors.divider)
                : BorderSide.none,
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label, style: AppTypography.labelLarge.copyWith(color: fg)),
      ),
    );
  }
}
