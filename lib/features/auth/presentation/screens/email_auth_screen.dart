import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import 'package:go_router/go_router.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  // Step 1: 이메일 입력 → OTP 발송
  // Step 2: 비밀번호 설정
  // Step 3: OTP 코드 입력 → 가입 완료
  int _step = 1;
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  String _submittedEmail = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // Step 1 → Step 2: 이메일 입력 후 OTP 발송
  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalidEmail)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final exists =
          await ref.read(authRepositoryProvider).checkEmailExists(email);
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.emailAlreadyExists)),
          );
          context.go(AppRoutes.login);
        }
        return;
      }

      await ref.read(authRepositoryProvider).sendEmailOtp(email);
      _submittedEmail = email;
      if (mounted) setState(() => _step = 2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.sendOtpFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Step 2 → Step 3: 비밀번호 유효성 검사 후 OTP 입력 단계로
  void _confirmPassword() {
    final pw = _pwCtrl.text.trim();
    if (pw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.passwordTooShort)),
      );
      return;
    }
    if (pw != _pwConfirmCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.passwordMismatch)),
      );
      return;
    }
    setState(() => _step = 3);
  }

  // Step 3: OTP 인증 + 비밀번호 설정 + 화면 이동 (한 번에 처리)
  Future<void> _completeSignup() async {
    final token = _otpCtrl.text.trim();
    if (token.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enterSixDigitCode)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyEmailOtp(_submittedEmail, token);
      await ref.read(authRepositoryProvider).setPassword(_pwCtrl.text.trim());
      if (mounted) context.go(AppRoutes.babySetup);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.signupFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailOtp(_submittedEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.resendSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.resendFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(),
        title: Text(context.l10n.emailSignupTitle, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: _step == 1
              ? _buildStep1Email()
              : _step == 2
                  ? _buildStep2Password()
                  : _buildStep3Otp(),
        ),
      ),
    );
  }

  // ── Step 1: 이메일 입력 ──────────────────────────────────────────────────────

  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),

        Text(
          context.l10n.enterEmailPrompt,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceMuted),
        ),
        const SizedBox(height: AppSpacing.lg),

        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          style: AppTypography.bodyMedium,
          decoration: _inputDecoration(hintText: 'example@email.com'),
        ),

        const SizedBox(height: AppSpacing.xl),

        _primaryButton(
          label: context.l10n.sendVerification,
          onPressed: _loading ? null : _sendOtp,
        ),

        const SizedBox(height: AppSpacing.lg),

        Center(
          child: TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: Text(
              context.l10n.alreadyHaveAccount,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 2: 비밀번호 설정 ────────────────────────────────────────────────────

  Widget _buildStep2Password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),

        const Icon(Icons.lock_outline, size: 56, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),

        Text(
          context.l10n.setPasswordTitle,
          style: AppTypography.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.setPasswordHint,
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.onSurfaceMuted),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxl),

        TextField(
          controller: _pwCtrl,
          obscureText: true,
          autofocus: true,
          style: AppTypography.bodyMedium,
          decoration: _inputDecoration(hintText: context.l10n.passwordInput),
        ),

        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: _pwConfirmCtrl,
          obscureText: true,
          style: AppTypography.bodyMedium,
          decoration: _inputDecoration(hintText: context.l10n.passwordConfirm),
        ),

        const SizedBox(height: AppSpacing.xl),

        _primaryButton(
          label: context.l10n.next,
          onPressed: _confirmPassword,
        ),
      ],
    );
  }

  // ── Step 3: OTP 코드 입력 ────────────────────────────────────────────────────

  Widget _buildStep3Otp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),

        const Icon(Icons.mark_email_read_outlined,
            size: 56, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),

        Text(
          context.l10n.enterOtpTitle,
          style: AppTypography.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _submittedEmail,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.enterOtpHint,
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.onSurfaceMuted),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxl),

        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTypography.titleLarge,
          decoration: _inputDecoration(
            hintText: '000000',
            hintStyle: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurfaceMuted),
            counterText: '',
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        _primaryButton(
          label: context.l10n.completeSignup,
          onPressed: _loading ? null : _completeSignup,
        ),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: TextButton(
            onPressed: _loading ? null : _resendOtp,
            child: Text(
              context.l10n.resendEmail,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.onSurfaceMuted),
            ),
          ),
        ),
      ],
    );
  }

  // ── 공통 위젯 헬퍼 ──────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hintText,
    TextStyle? hintStyle,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle ??
          AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceMuted),
      counterText: counterText,
      filled: true,
      fillColor: AppColors.surfaceVariant,
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
    );
  }

  Widget _primaryButton({
    required String label,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style:
                    AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
