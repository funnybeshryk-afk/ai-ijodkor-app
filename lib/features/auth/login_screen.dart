import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/ui.dart';
import 'validators.dart';

/// Mockup «1 · Kirish».
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await repo.signIn(email: _email.text.trim(), password: _password.text);
      // The router redirects to the role's home once the session arrives.
    } on InvalidCredentialsException {
      _error = l10n.errorInvalidCredentials;
    } catch (_) {
      _error = l10n.errorGeneric;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s6,
                AppSpace.s6,
                AppSpace.s6,
                AppSpace.s8,
              ),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSize.formMaxWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: LanguageSwitcher(),
                            ),
                            const SizedBox(height: AppSpace.s14),
                            const AppLogo(),
                            const SizedBox(height: AppSpace.labelGap),
                            Text(
                              l10n.loginTagline,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpace.s11),
                            AppTextField(
                              fieldKey: const Key('login_email'),
                              label: l10n.emailLabel,
                              hint: l10n.emailHint,
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: (v) => validateEmail(v, l10n),
                            ),
                            const SizedBox(height: AppSpace.s4),
                            AppTextField(
                              fieldKey: const Key('login_password'),
                              label: l10n.passwordLabel,
                              controller: _password,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _busy ? null : _submit(),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? l10n.errorPasswordRequired
                                  : null,
                              suffix: IconButton(
                                tooltip: _obscure
                                    ? l10n.showPassword
                                    : l10n.hidePassword,
                                color: colors.inkMuted,
                                icon: Icon(
                                  _obscure
                                      ? LucideIcons.eye
                                      : LucideIcons.eyeOff,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.push(Routes.forgotPassword),
                                child: Text(l10n.forgotPasswordLink),
                              ),
                            ),
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: AppText.label.copyWith(
                                  color: colors.danger,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpace.s3),
                            ],
                            PrimaryButton(
                              key: const Key('login_submit'),
                              label: l10n.signInButton,
                              trailingIcon: LucideIcons.arrowRight,
                              busy: _busy,
                              onPressed: _submit,
                            ),
                            const Spacer(),
                            const SizedBox(height: AppSpace.s8),
                            NotePanel(
                              icon: LucideIcons.info,
                              text: l10n.loginNote,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
