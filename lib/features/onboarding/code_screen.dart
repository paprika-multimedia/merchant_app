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
import '../../primitives/icons.dart';
import '../../primitives/screen_header.dart';
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
  const CodeScreen({super.key, required this.kind, this.addMode = false});

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
        final merchant = await MerchantsApi(
          dio,
        ).claim(_code, idempotencyKey: const Uuid().v4());
        final session = ref.read(sessionProvider).value;
        if (session != null) {
          ref.read(sessionProvider.notifier).updateMerchants([
            ...session.merchants,
            merchant,
          ]);
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
    final sub = isMerchant ? t.codeSubMerchant : t.codeSubCompany;
    final step = isMerchant ? 2 : 1;

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaprikaScreenHeader(
              onBack: () => context.pop(),
              overline: widget.addMode
                  ? null
                  : Text(t.codeStep(step).toUpperCase()),
              title: Text(
                widget.addMode
                    ? t.codeAdd
                    : (isMerchant ? t.codeTitleMerchant : t.codeTitleCompany),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMerchant ? t.codeTitleMerchant : t.codeTitleCompany,
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
                    // Fix 6a: confirmed-company chip on merchant code step
                    if (isMerchant) ...[
                      const SizedBox(height: 16),
                      _ConfirmedCompanyCard(ref: ref, t: t),
                    ],
                    const SizedBox(height: 28),
                    CodeInput(
                      onChanged: (v) => setState(() => _code = v),
                      error: _error,
                      showCounter: false,
                    ),
                    const SizedBox(height: 8),
                    // Inline counter + camera row (JSX §screens-onboarding)
                    Row(
                      children: [
                        Text(
                          '${_code.length} / 20',
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTokens.inkTertiary,
                          ),
                        ),
                        const Spacer(),
                        AppButton(
                          label: t.codeCamera,
                          variant: AppButtonVariant.ghost,
                          size: AppButtonSize.sm,
                          leading: const CameraIcon(
                            size: 14,
                            color: AppTokens.inkSecondary,
                          ),
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
                      ],
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
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmed-company context card shown on the merchant code step.
///
/// Visual matches screens-onboarding.jsx confirmedCompany block:
/// surface + border container, store icon in accentSoft box, company label
/// + name, monospace short code.
class _ConfirmedCompanyCard extends StatelessWidget {
  const _ConfirmedCompanyCard({required this.ref, required this.t});

  final WidgetRef ref;
  final AppL10n t;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    final company = session.company;
    // Show first 8 chars of the code as a short identifier (matches JSX visual)
    final shortCode = company.code.length >= 8
        ? company.code.substring(0, 8)
        : company.code;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTokens.accentSoft,
              borderRadius: BorderRadius.circular(AppTokens.sp8),
            ),
            alignment: Alignment.center,
            child: const StoreIcon(size: 16, color: AppTokens.accentDeep),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.codeCompanyLabel.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.inkTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  company.name,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink,
                  ),
                ),
              ],
            ),
          ),
          Text(
            shortCode,
            style: const TextStyle(
              fontFamily: AppTokens.fontMono,
              fontSize: 12,
              color: AppTokens.inkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
