import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../primitives/card.dart';
import '../../primitives/icons.dart';
import '../../primitives/screen_header.dart';
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
    final session = ref.watch(sessionProvider).value;
    final companyName = session?.company.name ?? '';

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaprikaScreenHeader(
              onBack: () => context.go('/dashboard/company'),
              title: Text(t.addmerchantHeader),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.sp22,
                  AppTokens.sp16,
                  AppTokens.sp22,
                  AppTokens.sp28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main heading
                    Text(
                      t.addmerchantTitle(companyName),
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppTokens.sp10),

                    // Description
                    Text(
                      t.addmerchantBody,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 14,
                        color: AppTokens.inkSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppTokens.sp28),

                    // Scan method card
                    _MethodCard(
                      icon: const QrIcon(color: AppTokens.accent),
                      iconBgColor: AppTokens.accentSoft,
                      title: t.addmerchantMethodScan,
                      subtitle: t.addmerchantMethodScanSub,
                      onTap: () => context.push(
                        '/scan/merchant',
                        extra: {'addMode': true},
                      ),
                    ),
                    const SizedBox(height: AppTokens.sp12),

                    // Code method card
                    _MethodCard(
                      icon: const KeyboardIcon(color: AppTokens.inkSecondary),
                      iconBgColor: AppTokens.surfaceAlt,
                      title: t.addmerchantMethodCode,
                      subtitle: t.addmerchantMethodCodeSub,
                      onTap: () => context.push(
                        '/code/merchant',
                        extra: {'addMode': true},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tip — bold "Tip." prefix, no emoji (project no-emoji rule)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.sp22,
                0,
                AppTokens.sp22,
                AppTokens.sp28,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppTokens.sp14),
                decoration: BoxDecoration(
                  color: AppTokens.accentWash,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable method card component with scaling animation
class _MethodCard extends StatefulWidget {
  const _MethodCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_MethodCard> createState() => _MethodCardState();
}

class _MethodCardState extends State<_MethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: widget.icon,
              ),
              const SizedBox(width: AppTokens.sp14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppTokens.sp4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 13,
                        color: AppTokens.inkSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.sp10),
              const ChevronIcon(
                size: 20,
                color: AppTokens.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
