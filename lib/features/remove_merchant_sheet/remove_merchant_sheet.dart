import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/merchant.dart';
import '../../net/api/merchants_api.dart';
import '../../net/dio_client.dart';
import '../../primitives/button.dart';
import '../../primitives/field.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';

/// Remove Merchant bottom sheet — Handoff §4.5.
///
/// Three internal states: settings → confirm (type name) → success.
/// Implemented as one sheet with internal state per Handoff §11.3.
class RemoveMerchantSheet extends ConsumerStatefulWidget {
  const RemoveMerchantSheet({
    super.key,
    required this.merchant,
    required this.siblingMerchants,
  });

  final Merchant merchant;
  final List<Merchant> siblingMerchants;

  @override
  ConsumerState<RemoveMerchantSheet> createState() =>
      _RemoveMerchantSheetState();
}

enum _SheetStep { settings, confirm, success }

class _RemoveMerchantSheetState extends ConsumerState<RemoveMerchantSheet> {
  _SheetStep _step = _SheetStep.settings;
  String _confirmText = '';
  bool _loading = false;
  String? _error;

  bool get _nameMatches =>
      _confirmText.trim().toLowerCase() ==
      widget.merchant.name.trim().toLowerCase();

  Future<void> _remove() async {
    if (!_nameMatches) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = await ref.read(dioProvider.future);
      await MerchantsApi(dio).remove(
        widget.merchant.id,
        confirmName: _confirmText.trim(),
      );
      ref.read(sessionProvider.notifier).removeMerchant(widget.merchant.id);
      setState(() => _step = _SheetStep.success);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        16,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: switch (_step) {
        _SheetStep.settings => _buildSettings(t),
        _SheetStep.confirm => _buildConfirm(t),
        _SheetStep.success => _buildSuccess(t),
      },
    );
  }

  Widget _buildSettings(AppL10n t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(),
        const SizedBox(height: 16),
        Text(
          t.merchantSettings,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTokens.ink,
          ),
        ),
        const SizedBox(height: 20),
        // Share QR (placeholder)
        _SettingsRow(
          icon: Icons.qr_code,
          label: t.merchantShareQr,
          sub: t.merchantShareQrSub,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        Text(
          t.merchantDanger,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTokens.danger,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsRow(
          icon: Icons.delete_outline,
          label: t.merchantRemove,
          sub: t.merchantRemoveSub(widget.merchant.name),
          danger: true,
          onTap: () => setState(() => _step = _SheetStep.confirm),
        ),
        const SizedBox(height: 16),
        Center(
          child: AppButton(
            label: t.commonClose,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirm(AppL10n t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(),
        const SizedBox(height: 16),
        Text(
          t.merchantRemoveTitle(widget.merchant.name),
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTokens.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.merchantRemoveBody,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 14,
            color: AppTokens.inkSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        AppField(
          label: t.merchantRemoveTypeLabel,
          placeholder: t.merchantRemoveConfirm(widget.merchant.name),
          onChanged: (v) => setState(() => _confirmText = v),
          error: _error,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: t.merchantRemove,
          variant: AppButtonVariant.danger,
          size: AppButtonSize.lg,
          block: true,
          disabled: !_nameMatches || _loading,
          onPressed: _remove,
        ),
        const SizedBox(height: 8),
        Center(
          child: AppButton(
            label: t.commonCancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => setState(() => _step = _SheetStep.settings),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(AppL10n t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTokens.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppTokens.success, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            t.merchantRemoved,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTokens.ink,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            t.merchantRemovedSub(widget.merchant.name),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 14,
              color: AppTokens.inkSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Sibling merchants to switch to
        if (widget.siblingMerchants.isNotEmpty) ...[
          Text(
            t.merchantRemovedSwitch,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 13,
              color: AppTokens.inkTertiary,
            ),
          ),
          const SizedBox(height: 8),
          for (final m in widget.siblingMerchants)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppButton(
                label: m.name,
                variant: AppButtonVariant.secondary,
                block: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/dashboard/merchant/${m.id}');
                },
              ),
            ),
        ],
        AppButton(
          label: t.merchantRemovedBack,
          variant: AppButtonVariant.ghost,
          block: true,
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/dashboard/company');
          },
        ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppTokens.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: danger ? AppTokens.dangerSoft : AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: danger ? AppTokens.danger : AppTokens.ink, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: danger ? AppTokens.danger : AppTokens.ink,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 12,
                      color: AppTokens.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: danger
                    ? AppTokens.danger.withOpacity(0.5)
                    : AppTokens.inkDisabled),
          ],
        ),
      ),
    );
  }
}
