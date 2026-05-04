import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../brand/paprika_lockup.dart';
import '../../primitives/button.dart';
import '../../theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Welcome screen — Handoff §4.1.
///
/// Static splash with the brand lockup and two CTAs:
/// - Scan company QR → /scan/company
/// - Enter code → /code/company
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.sp22),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const PaprikaLockup(size: 32),
              const SizedBox(height: AppTokens.sp22),
              Text(
                t.welcomeTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppTokens.inkSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 4),
              AppButton(
                label: t.welcomeScan,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.lg,
                block: true,
                onPressed: () => context.push('/scan/company'),
              ),
              const SizedBox(height: AppTokens.sp12),
              AppButton(
                label: t.welcomeCode,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.lg,
                block: true,
                onPressed: () => context.push('/code/company'),
              ),
              const SizedBox(height: AppTokens.sp28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.welcomeHelp,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 13,
                      color: AppTokens.inkTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {}, // contact admin — placeholder
                    child: Text(
                      t.welcomeHelpCta,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.sp16),
            ],
          ),
        ),
      ),
    );
  }
}
