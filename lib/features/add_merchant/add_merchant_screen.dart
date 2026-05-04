import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../primitives/button.dart';
import '../../primitives/card.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';

/// Add Merchant screen — Handoff §4.6.
///
/// Entry point for mid-session add flow. Distinguishes from onboarding
/// via addMode=true passed to scan/code screens.
class AddMerchantScreen extends ConsumerWidget {
  const AddMerchantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppL10n.of(context);
    final session = ref.watch(sessionProvider).valueOrNull;
    final companyName = session?.company.name ?? '';

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(
        backgroundColor: AppTokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTokens.ink),
          onPressed: () => context.go('/dashboard/company'),
          tooltip: t.commonClose,
        ),
        title: Text(
          t.addmerchantHeader,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTokens.ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.addmerchantTitle(companyName),
              style: const TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTokens.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.addmerchantBody,
              style: const TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 14,
                color: AppTokens.inkSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Scan method
            AppCard(
              onTap: () => context.push(
                '/scan/merchant',
                extra: {'addMode': true},
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTokens.accentSoft,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: const Icon(Icons.qr_code_scanner,
                        color: AppTokens.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.addmerchantMethodScan,
                            style: const TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.ink,
                            )),
                        Text(t.addmerchantMethodScanSub,
                            style: const TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 13,
                              color: AppTokens.inkSecondary,
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppTokens.inkDisabled),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Code method
            AppCard(
              onTap: () => context.push(
                '/code/merchant',
                extra: {'addMode': true},
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTokens.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: const Icon(Icons.keyboard,
                        color: AppTokens.inkSecondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.addmerchantMethodCode,
                            style: const TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.ink,
                            )),
                        Text(t.addmerchantMethodCodeSub,
                            style: const TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 13,
                              color: AppTokens.inkSecondary,
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppTokens.inkDisabled),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTokens.accentWash,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ',
                      style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 13,
                          color: AppTokens.inkSecondary,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: '${t.addmerchantTipLabel} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTokens.accentDeep,
                            ),
                          ),
                          TextSpan(text: t.addmerchantTipBody),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
