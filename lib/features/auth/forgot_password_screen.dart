import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../data/providers.dart';
import '../../core/theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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
      await repo.sendPasswordReset(_email.text.trim());
      _sent = true;
    } catch (_) {
      _error = l10n.errorGeneric;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _backToLogin() =>
      context.canPop() ? context.pop() : context.go(Routes.login);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backLabel,
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: _backToLogin,
        ),
        title: Text(l10n.resetPasswordTitle),
      ),
      body: SafeArea(
        child: _sent
            ? MessageView(
                icon: LucideIcons.mail,
                title: l10n.resetLinkSent,
                actions: [
                  PrimaryButton(
                    label: l10n.backToLoginButton,
                    onPressed: _backToLogin,
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpace.s6),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSize.formMaxWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.resetPasswordHint,
                            style: AppText.bodyLg.copyWith(
                              color: colors.inkSoft,
                            ),
                          ),
                          const SizedBox(height: AppSpace.s6),
                          AppTextField(
                            label: l10n.emailLabel,
                            hint: l10n.emailHint,
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) => validateEmail(v, l10n),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpace.s4),
                            Text(
                              _error!,
                              style: AppText.label.copyWith(
                                color: colors.danger,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AppSpace.s6),
                          PrimaryButton(
                            label: l10n.sendResetLinkButton,
                            icon: LucideIcons.send,
                            busy: _busy,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
