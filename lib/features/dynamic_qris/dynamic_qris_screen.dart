import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';
import '../../net/api/merchants_api.dart';
import '../../net/api/transactions_api.dart';
import '../../net/dio_client.dart';
import '../../primitives/button.dart';
import '../../primitives/card.dart';
import '../../primitives/chip.dart';
import '../../primitives/field.dart';
import '../../primitives/icons.dart';
import '../../primitives/keypad.dart';
import '../../state/recent_amounts.dart';
import '../../theme/tokens.dart';

/// Dynamic QRIS flow — Handoff §4.7.
///
/// Three steps: amount entry → QR display → paid.
enum _QrisStep { amount, qr, paid }

class DynamicQrisScreen extends ConsumerStatefulWidget {
  const DynamicQrisScreen({super.key, required this.merchantId});

  final String merchantId;

  @override
  ConsumerState<DynamicQrisScreen> createState() =>
      _DynamicQrisScreenState();
}

class _DynamicQrisScreenState extends ConsumerState<DynamicQrisScreen> {
  _QrisStep _step = _QrisStep.amount;
  String _amountStr = '';
  String _note = '';
  String? _idempotencyKey;

  Transaction? _txn;
  String? _qrPayload;
  DateTime? _expiresAt;
  Timer? _expireTimer;
  String? _error;
  bool _loading = false;

  int get _amount => int.tryParse(_amountStr) ?? 0;

  @override
  void dispose() {
    _expireTimer?.cancel();
    super.dispose();
  }

  // ─── Amount keypad handlers ─────────────────────────────────────────────────

  void _onDigit(String d) {
    setState(() {
      if (_amountStr.isEmpty && d == '0') return;
      _amountStr = (_amountStr + d).replaceFirst(RegExp(r'^0+'), '');
    });
  }

  void _onBackspace() {
    if (_amountStr.isNotEmpty) {
      setState(() => _amountStr = _amountStr.substring(0, _amountStr.length - 1));
    }
  }

  void _onTripleZero() {
    setState(() {
      if (_amountStr.isEmpty) return;
      _amountStr = ('${_amountStr}000').replaceFirst(RegExp(r'^0+'), '');
    });
  }

  void _clearAmount() => setState(() => _amountStr = '');

  // ─── Generate QR ────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    if (_amount <= 0 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      // Generate idempotency key once per gesture
      _idempotencyKey ??= const Uuid().v4();
    });

    try {
      final dio = await ref.read(dioProvider.future);
      final result = await MerchantsApi(dio).createQris(
        widget.merchantId,
        amount: _amount,
        note: _note.isNotEmpty ? _note : null,
        idempotencyKey: _idempotencyKey!,
      );

      final txn =
          Transaction.fromJson(result['transaction'] as Map<String, dynamic>);
      final qr = result['qr_payload'] as String;
      final exp = DateTime.parse(result['expires_at'] as String);

      // Push amount to recents
      await ref
          .read(recentAmountsProvider((widget.merchantId, 'qris')).notifier)
          .push(_amount);

      setState(() {
        _txn = txn;
        _qrPayload = qr;
        _expiresAt = exp;
        _step = _QrisStep.qr;
        _loading = false;
        _idempotencyKey = null; // discard on success
      });

      _startExpireTimer();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
        // Keep the same _idempotencyKey so retry reuses it
      });
    }
  }

  void _startExpireTimer() {
    _expireTimer?.cancel();
    _expireTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _expiresAt?.difference(DateTime.now());
      if (remaining == null || remaining.isNegative) {
        _expireTimer?.cancel();
        if (mounted) {
          // Show expired UI
          setState(() {
            _txn = _txn?.copyWith(status: TransactionStatus.expired);
          });
        }
      } else {
        if (mounted) setState(() {}); // rebuild for countdown
      }
    });
  }

  // ─── Cancel ─────────────────────────────────────────────────────────────────

  Future<void> _cancel() async {
    final txnId = _txn?.id;
    if (txnId == null) {
      setState(() {
        _step = _QrisStep.amount;
        _txn = null;
        _qrPayload = null;
      });
      return;
    }
    try {
      final dio = await ref.read(dioProvider.future);
      await TransactionsApi(dio).cancel(
        txnId,
        idempotencyKey: const Uuid().v4(),
      );
    } catch (_) {}
    _expireTimer?.cancel();
    setState(() {
      _step = _QrisStep.amount;
      _txn = null;
      _qrPayload = null;
      _idempotencyKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final fmt = NumberFormat('#,###', 'id_ID');
    final recents =
        ref.watch(recentAmountsProvider((widget.merchantId, 'qris')));

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(
        backgroundColor: AppTokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const CloseIcon(size: 20, color: AppTokens.ink),
          onPressed: _step == _QrisStep.paid
              ? () => context.go(
                    '/dashboard/merchant/${widget.merchantId}')
              : () {
                  if (_step == _QrisStep.qr) {
                    _cancel();
                  } else {
                    context.pop();
                  }
                },
        ),
        title: Text(
          switch (_step) {
            _QrisStep.amount => t.qrisHeaderAmount,
            _QrisStep.qr => t.qrisHeaderWaiting,
            _QrisStep.paid => t.qrisHeaderPaid,
          },
          style: const TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTokens.ink,
          ),
        ),
      ),
      body: switch (_step) {
        _QrisStep.amount => _buildAmount(t, fmt, recents),
        _QrisStep.qr => _buildQr(t, fmt),
        _QrisStep.paid => _buildPaid(t, fmt),
      },
    );
  }

  // ─── Amount step ─────────────────────────────────────────────────────────

  Widget _buildAmount(AppL10n t, NumberFormat fmt, List<int> recents) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Amount card
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            t.qrisAmount.toUpperCase(),
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
                              onTap: _clearAmount,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTokens.surfaceAlt,
                                  borderRadius: BorderRadius.circular(
                                      AppTokens.radiusXs),
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
                              _amount > 0
                                  ? fmt.format(_amount)
                                  : '0',
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
                // Preset chips
                Wrap(
                  spacing: 8,
                  children: recents.map((a) {
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _amountStr = a.toString()),
                      child: AppChip(
                        label: fmt.format(a),
                        tone: ChipTone.neutral,
                        size: ChipSize.md,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Note field
                AppField(
                  label: t.qrisNote,
                  placeholder: t.qrisNotePh,
                  onChanged: (v) => setState(() => _note = v),
                  maxLength: 80,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                          color: AppTokens.danger, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Keypad
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
              label: _loading ? '...' : t.qrisGenerate,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.lg,
              block: true,
              disabled: _amount <= 0 || _loading,
              onPressed: _generate,
            ),
          ),
        ),
      ],
    );
  }

  // ─── QR step ─────────────────────────────────────────────────────────────

  Widget _buildQr(AppL10n t, NumberFormat fmt) {
    final isExpired = _txn?.status == TransactionStatus.expired;
    final remaining =
        _expiresAt?.difference(DateTime.now()) ?? Duration.zero;
    final mins = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                if (_qrPayload != null)
                  QrImageView(
                    data: _qrPayload!,
                    size: 240,
                    backgroundColor: Colors.white,
                  )
                else
                  const SizedBox(height: 240),
                const SizedBox(height: 12),
                Text(
                  'IDR ${fmt.format(_amount)}',
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTokens.ink,
                  ),
                ),
                if (_note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _note,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 14,
                      color: AppTokens.inkSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                isExpired
                    ? Text(
                        t.txStatusExpired,
                        style: const TextStyle(
                          color: AppTokens.danger,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTokens.fontDisplay,
                        ),
                      )
                    : Text(
                        t.qrisExpiresLive(
                            '$mins:${secs.toString().padLeft(2, '0')}'),
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 13,
                          color: AppTokens.inkSecondary,
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: t.qrisCancel,
                  variant: AppButtonVariant.secondary,
                  onPressed: _cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Paid step ────────────────────────────────────────────────────────────

  Widget _buildPaid(AppL10n t, NumberFormat fmt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTokens.successSoft,
              shape: BoxShape.circle,
            ),
            child: const CheckIcon(color: AppTokens.success, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            t.qrisPaidTitle,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTokens.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'IDR ${fmt.format(_amount)}',
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTokens.accent,
            ),
          ),
          const SizedBox(height: 24),
          if (_txn != null)
            AppCard(
              child: Column(
                children: [
                  if (_txn!.payer?.maskedPhone != null)
                    _DetailRow(
                      label: t.qrisRowFrom,
                      value: _txn!.payer!.maskedPhone!,
                    ),
                  if (_txn!.payer?.issuerName != null)
                    _DetailRow(
                      label: t.qrisRowMethod,
                      value: 'QRIS · ${_txn!.payer!.issuerName!}',
                    ),
                  _DetailRow(
                    label: t.qrisRowRef,
                    value: _txn!.ref,
                    mono: true,
                  ),
                  if (_txn!.paidAt != null)
                    _DetailRow(
                      label: t.qrisRowAt,
                      value: _txn!.paidAt!,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          AppButton(
            label: t.qrisPaidDone,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.lg,
            block: true,
            onPressed: () =>
                context.go('/dashboard/merchant/${widget.merchantId}'),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: t.qrisPaidAnother,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.lg,
            block: true,
            onPressed: () => setState(() {
              _step = _QrisStep.amount;
              _txn = null;
              _qrPayload = null;
              _amountStr = '';
              _note = '';
              _idempotencyKey = null;
            }),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 13,
                color: AppTokens.inkSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily:
                    mono ? AppTokens.fontMono : AppTokens.fontDisplay,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
