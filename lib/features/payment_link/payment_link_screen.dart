import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';
import '../../net/api/merchants_api.dart';
import '../../net/dio_client.dart';
import '../../primitives/button.dart';
import '../../primitives/card.dart';
import '../../primitives/chip.dart';
import '../../primitives/field.dart';
import '../../primitives/icons.dart';
import '../../primitives/keypad.dart';
import '../../primitives/screen_header.dart';
import '../../state/recent_amounts.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';

/// Payment Link flow — Handoff §4.8.
///
/// Two steps: form (amount + title + customer + invoice) → success (share).
enum _LinkStep { form, success }

class PaymentLinkScreen extends ConsumerStatefulWidget {
  const PaymentLinkScreen({super.key, required this.merchantId});

  final String merchantId;

  @override
  ConsumerState<PaymentLinkScreen> createState() => _PaymentLinkScreenState();
}

class _PaymentLinkScreenState extends ConsumerState<PaymentLinkScreen> {
  _LinkStep _step = _LinkStep.form;
  String _amountStr = '';
  String _title = '';
  String _customer = '';
  bool _autoInvoice = true;
  String _manualInvoice = '';
  bool _loading = false;
  String? _error;
  String? _idempotencyKey;

  Transaction? _txn;
  bool _showQrOverlay = false;
  bool _msgEdited = false;
  String _msg = '';
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_amountStr) ?? 0;
  bool get _canCreate => _amount > 0 && _title.trim().isNotEmpty && !_loading;

  void _onDigit(String d) {
    setState(() {
      if (_amountStr.isEmpty && d == '0') return;
      _amountStr = (_amountStr + d).replaceFirst(RegExp(r'^0+'), '');
    });
  }

  void _onBackspace() {
    if (_amountStr.isNotEmpty) {
      setState(
        () => _amountStr = _amountStr.substring(0, _amountStr.length - 1),
      );
    }
  }

  void _onTripleZero() {
    setState(() {
      if (_amountStr.isEmpty) return;
      _amountStr = ('${_amountStr}000').replaceFirst(RegExp(r'^0+'), '');
    });
  }

  String _buildDefaultMsg(AppL10n t, NumberFormat fmt) {
    final greeting = _customer.trim().isNotEmpty
        ? t.linkMessageGreeting(_customer.trim().split(' ').first)
        : t.linkMessageGreetingFallback;
    final what = _title.trim().isNotEmpty
        ? t.linkMessageBodyWithTitle(_title.trim())
        : t.linkMessageBodyNoTitle;
    final amt = _amount > 0
        ? t.linkMessageAmountSuffix(fmt.format(_amount))
        : '';
    final link = _txn?.linkUrl ?? '';
    final merchant =
        ref
            .read(sessionProvider)
            .value
            ?.merchants
            .firstWhere(
              (m) => m.id == widget.merchantId,
              orElse: () => throw StateError('merchant'),
            )
            .name ??
        '';
    return '$greeting\n${t.linkMessageBody(what, amt, link, merchant)}';
  }

  Future<void> _create() async {
    if (!_canCreate) return;
    setState(() {
      _loading = true;
      _error = null;
      _idempotencyKey ??= const Uuid().v4();
    });

    try {
      final dio = await ref.read(dioProvider.future);
      final result = await MerchantsApi(dio).createLink(
        widget.merchantId,
        title: _title.trim(),
        amount: _amount,
        customer: _customer.trim().isNotEmpty ? _customer.trim() : null,
        invoiceNumber: !_autoInvoice && _manualInvoice.trim().isNotEmpty
            ? _manualInvoice.trim()
            : null,
        idempotencyKey: _idempotencyKey!,
      );
      final txn = Transaction.fromJson(
        result['transaction'] as Map<String, dynamic>,
      );

      await ref
          .read(recentAmountsProvider((widget.merchantId, 'link')).notifier)
          .push(_amount);

      setState(() {
        _txn = txn;
        _step = _LinkStep.success;
        _loading = false;
        _idempotencyKey = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final fmt = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                PaprikaScreenHeader(
                  onBack: () =>
                      context.go('/dashboard/merchant/${widget.merchantId}'),
                  overline: Text(t.linkTitle.toUpperCase()),
                  title: Text(
                    _step == _LinkStep.form
                        ? t.linkHeaderCreate
                        : t.linkHeaderShare,
                  ),
                ),
                Expanded(
                  child: _step == _LinkStep.form
                      ? _buildForm(t, fmt)
                      : _buildSuccess(t, fmt),
                ),
              ],
            ),
            // Fullscreen QR overlay
            if (_showQrOverlay && _txn?.linkUrl != null)
              _QrOverlay(
                linkUrl: _txn!.linkUrl!,
                title: _txn!.title,
                amount: _amount,
                fmt: fmt,
                onClose: () => setState(() => _showQrOverlay = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppL10n t, NumberFormat fmt) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Amount card
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            t.linkAmount.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTokens.inkSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          if (_amount > 0)
                            GestureDetector(
                              onTap: () => setState(() => _amountStr = ''),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTokens.surfaceAlt,
                                  borderRadius: BorderRadius.circular(
                                    AppTokens.radiusXs,
                                  ),
                                ),
                                child: Text(
                                  t.qrisAmountClear,
                                  style: const TextStyle(
                                    fontFamily: AppTokens.fontDisplay,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTokens.inkSecondary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            'IDR ',
                            style: TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.inkSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _amount > 0 ? fmt.format(_amount) : '0',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: _amount > 0
                                    ? AppTokens.ink
                                    : AppTokens.inkDisabled,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Fixed preset chips — always 5K/10K/25K/50K/100K (JSX spec)
                _PresetRow(
                  onTap: (v) => setState(() => _amountStr = v.toString()),
                ),
                const SizedBox(height: 16),
                // Title
                _formField(
                  label: t.linkFieldTitle,
                  placeholder: t.linkFieldTitlePh,
                  onChanged: (v) => setState(() => _title = v),
                  maxLength: 40,
                ),
                const SizedBox(height: 12),
                // Customer
                _formField(
                  label: t.linkFieldCustomer,
                  placeholder: t.linkFieldCustomerPh,
                  onChanged: (v) => setState(() => _customer = v),
                ),
                const SizedBox(height: 12),
                // Invoice number
                _InvoiceField(
                  autoInvoice: _autoInvoice,
                  onToggle: (v) => setState(() => _autoInvoice = v),
                  onChanged: (v) => setState(() => _manualInvoice = v),
                  merchantId: widget.merchantId,
                  t: t,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppTokens.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: AmountKeypad(
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onTripleZero: _onTripleZero,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SafeArea(
            top: false,
            child: AppButton(
              label: _loading ? '...' : t.linkCreate,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.lg,
              block: true,
              disabled: !_canCreate,
              onPressed: _create,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required String label,
    required String placeholder,
    required ValueChanged<String> onChanged,
    int? maxLength,
  }) {
    return AppField(
      label: label,
      placeholder: placeholder,
      onChanged: onChanged,
      maxLength: maxLength,
    );
  }

  Widget _buildSuccess(AppL10n t, NumberFormat fmt) {
    if (_txn == null) return const SizedBox.shrink();
    if (!_msgEdited) {
      _msg = _buildDefaultMsg(t, fmt);
      if (_msgController.text != _msg) {
        _msgController.text = _msg;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Link card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _txn!.title,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.ink,
                  ),
                ),
                if (_txn!.customer != null)
                  Text(
                    _txn!.customer!,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 14,
                      color: AppTokens.inkSecondary,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'IDR ${fmt.format(_txn!.amount)}',
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTokens.accent,
                  ),
                ),
                const SizedBox(height: 8),
                AppChip(
                  label: t.linkLive,
                  tone: ChipTone.success,
                  leading: const Icon(Icons.circle, size: 6),
                ),
                if (_txn!.linkUrl != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _txn!.linkUrl!,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontMono,
                            fontSize: 12,
                            color: AppTokens.accent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const CopyIcon(
                          size: 18,
                          color: AppTokens.inkSecondary,
                        ),
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: _txn!.linkUrl!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Message to share
          Text(
            t.linkMessage,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.inkSecondary,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppField(
                  controller: _msgController,
                  onChanged: (v) {
                    _msg = v;
                    _msgEdited = true;
                  },
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppButton(
                      label: t.linkMessageCopy,
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: _msg)),
                    ),
                    if (_msgEdited) ...[
                      const SizedBox(width: 8),
                      AppButton(
                        label: t.linkMessageReset,
                        variant: AppButtonVariant.ghost,
                        size: AppButtonSize.sm,
                        onPressed: () => setState(() {
                          _msgEdited = false;
                          _msg = _buildDefaultMsg(t, fmt);
                        }),
                      ),
                    ],
                  ],
                ),
                Text(
                  t.linkMessageHelp,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 12,
                    color: AppTokens.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: t.linkShareVia,
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    if (_txn?.linkUrl != null) {
                      Share.share(
                        _msg,
                      ); // Placeholder — real share via url_launcher
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: t.linkShowQr,
                variant: AppButtonVariant.secondary,
                onPressed: () => setState(() => _showQrOverlay = true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fullscreen QR overlay — Handoff §4.8 "Show QR".
class _QrOverlay extends StatelessWidget {
  const _QrOverlay({
    required this.linkUrl,
    required this.title,
    required this.amount,
    required this.fmt,
    required this.onClose,
  });

  final String linkUrl;
  final String title;
  final int amount;
  final NumberFormat fmt;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    QrImageView(data: linkUrl, size: 240),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'IDR ${fmt.format(amount)}',
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      linkUrl,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontMono,
                        fontSize: 11,
                        color: AppTokens.accent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t.linkQrTapClose,
                style: const TextStyle(
                  color: Colors.white60,
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder for Share — real implementation uses url_launcher / share_plus.
class Share {
  static Future<void> share(String text) async {
    // TODO(share): integrate share_plus or url_launcher share intent
    await Clipboard.setData(ClipboardData(text: text));
  }
}

// ─── Fixed preset chips — 5K / 10K / 25K / 50K / 100K ──────────────────────

const _kPresets = [5000, 10000, 25000, 50000, 100000];

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.onTap});
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _kPresets.map((v) {
        final label = '${v ~/ 1000}K';
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: v != _kPresets.last ? 6 : 0,
            ),
            child: _AmountPresetChip(value: v, label: label, onTap: onTap),
          ),
        );
      }).toList(),
    );
  }
}

class _AmountPresetChip extends StatelessWidget {
  const _AmountPresetChip({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final int value;
  final String label;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(color: AppTokens.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTokens.ink,
          ),
        ),
      ),
    );
  }
}

class _InvoiceField extends StatelessWidget {
  const _InvoiceField({
    required this.autoInvoice,
    required this.onToggle,
    required this.onChanged,
    required this.merchantId,
    required this.t,
  });

  final bool autoInvoice;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onChanged;
  final String merchantId;
  final AppL10n t;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.linkFieldInvoice,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTokens.inkSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (autoInvoice)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.accentSoft,
                  borderRadius: BorderRadius.circular(AppTokens.radiusXs),
                ),
                child: Text(
                  t.linkFieldInvoiceAuto,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.accentDeep,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onToggle(false),
                child: Text(
                  t.linkFieldInvoiceClear,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 12,
                    color: AppTokens.inkSecondary,
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              AppField(
                placeholder: t.linkFieldInvoicePh,
                onChanged: onChanged,
                maxLength: 40,
                textCapitalization: TextCapitalization.characters,
                monospace: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onToggle(true),
                  child: Text(
                    t.linkFieldInvoiceRegen,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 12,
                      color: AppTokens.inkSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        Text(
          t.linkFieldInvoiceHelp,
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 12,
            color: AppTokens.inkTertiary,
          ),
        ),
      ],
    );
  }
}
