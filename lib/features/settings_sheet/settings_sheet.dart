import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../primitives/button.dart';
import '../../primitives/icons.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';

/// Settings bottom sheet — Handoff §4.4.1.
///
/// Contains: language toggle, logout.
/// Opened from the company dashboard gear icon.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppL10n.of(context);
    final locale = ref.watch(localeProvider);
    final session = ref.watch(sessionProvider).value;
    final companyName = session?.company.name ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        16,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTokens.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header row: icon plate + overline/company name (Fix 6 — restore icon plate)
          Row(
            children: [
              // 36×36 surfaceAlt rounded square containing SettingsIcon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTokens.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                alignment: Alignment.center,
                child: const SettingsIcon(size: 18, color: AppTokens.ink),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.settingsTitle.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.inkTertiary,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.ink,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Language toggle
          Text(
            t.settingsLanguage,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.inkSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _LangTab(
                    label: '🇮🇩 ${t.settingsLangId}',
                    active: locale == 'id',
                    onTap: () =>
                        ref.read(localeProvider.notifier).setLocale('id'),
                  ),
                ),
                Expanded(
                  child: _LangTab(
                    label: '🇬🇧 ${t.settingsLangEn}',
                    active: locale == 'en',
                    onTap: () =>
                        ref.read(localeProvider.notifier).setLocale('en'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Account section
          Text(
            t.settingsAccount,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.inkSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showLogoutConfirm(context, ref, companyName),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTokens.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                border: Border.all(color: AppTokens.border),
              ),
              child: Row(
                children: [
                  // 34×34 dangerSoft icon plate
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTokens.dangerSoft,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    alignment: Alignment.center,
                    child: const LogoutIcon(size: 18, color: AppTokens.danger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.settingsLogout,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.ink,
                          ),
                        ),
                        Text(
                          t.settingsLogoutSub,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 12,
                            color: AppTokens.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ChevronIcon(size: 18, color: AppTokens.inkDisabled),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Close button
          Center(
            child: AppButton(
              label: t.commonClose,
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirm(
    BuildContext context,
    WidgetRef ref,
    String companyName,
  ) async {
    final t = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.settingsLogoutConfirm(companyName)),
        content: Text(t.settingsLogoutSub),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.settingsLogoutStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              t.settingsLogoutGo,
              style: const TextStyle(color: AppTokens.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(sessionProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pop(); // close sheet
        context.go('/welcome');
      }
    }
  }
}

class _LangTab extends StatelessWidget {
  const _LangTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: active ? AppTokens.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusXs),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppTokens.ink : AppTokens.inkTertiary,
          ),
        ),
      ),
    );
  }
}
