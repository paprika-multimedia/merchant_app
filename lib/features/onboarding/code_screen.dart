import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../net/dio_client.dart';
import '../../net/api/merchants_api.dart';
import '../../net/api/sessions_api.dart';
import '../../primitives/button.dart';
import '../../primitives/code_input.dart';
import '../../state/session.dart';
import '../../state/active_merchant.dart';
import '../../theme/tokens.dart';

/// Which flow this code screen handles.
enum CodeScreenKind { company, merchant }

/// Enter Code screen — Handoff §4.3.
///
/// Used for both company-code entry (step 1) and merchant-code entry (step 2).
/// Passes [addMode] through for the merchant flow.
class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({
    super.key,
    required this.kind,
    this.addMode = false,
  });

  final CodeScreenKind kind;
  final bool addMode;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  String _code = '';
  bool _loading = false;
  String? _error;

  bool get _canContinue => _code.length == 20 && !_loading;

  Future<void> _onContinue() async {
    if (!_canContinue) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = await ref.read(dioProvider.future);

      if (widget.kind == CodeScreenKind.company) {
        final api = SessionsApi(dio);
        // Claim company — SessionsApi.claim handles the full response
        final response = await api.claim(
          companyCode: _code,
          platform: 'android', // TODO(platform-detect): use Platform.isIOS
          model: 'device',
        );
        // Persist tokens + session
        final storage = ref.read(secureStorageProvider);
        await storage.write('session_token', response.sessionToken);
        await storage.write('refresh_token', response.refreshToken);
        await storage.write('device_id', response.deviceId);

        // Navigate to merchant code entry
        if (!mounted) return;
        context.push('/code/merchant');
      } else {
        // Merchant claim
        final merchant = await MerchantsApi(dio).claim(
          _code,
          idempotencyKey: const Uuid().v4(),
        );
        final session = ref.read(sessionProvider).valueOrNull;
        if (session != null) {
          ref.read(sessionProvider.notifier).updateMerchants(
            [...session.merchants, merchant],
          );
        }
        await ref
            .read(activeMerchantIdProvider.notifier)
            .setActive(merchant.id);

        if (!mounted) return;
        if (widget.addMode) {
          context.go('/dashboard/merchant/${merchant.id}');
        } else {
          context.go('/dashboard/company');
        }
      }
    } on Exception catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final isMerchant = widget.kind == CodeScreenKind.merchant;
    final title =
        isMerchant ? t.codeTitleMerchant : t.codeTitleCompany;
    final sub = isMerchant ? t.codeSubMerchant : t.codeSubCompany;
    final step = isMerchant ? 2 : 1;

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(
        backgroundColor: AppTokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTokens.ink),
          onPressed: () => context.pop(),
          tooltip: t.commonBack,
        ),
        title: Text(
          widget.addMode ? t.codeAdd : t.codeStep(step),
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTokens.inkSecondary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              style: const TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 14,
                color: AppTokens.inkSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            CodeInput(
              onChanged: (v) => setState(() => _code = v),
              error: _error,
            ),
            const Spacer(),
            AppButton(
              label: t.codeContinue,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.lg,
              block: true,
              disabled: !_canContinue,
              onPressed: _onContinue,
            ),
            const SizedBox(height: 12),
            Center(
              child: AppButton(
                label: t.codeCamera,
                variant: AppButtonVariant.ghost,
                onPressed: () {
                  if (isMerchant) {
                    context.pushReplacement(
                      '/scan/merchant',
                      extra: {'addMode': widget.addMode},
                    );
                  } else {
                    context.pushReplacement('/scan/company');
                  }
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
