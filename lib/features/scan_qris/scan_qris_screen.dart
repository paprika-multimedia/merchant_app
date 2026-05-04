import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/merchant.dart';
import '../../net/api/merchants_api.dart';
import '../../net/dio_client.dart';
import '../../primitives/button.dart';
import '../../primitives/icons.dart';
import '../../primitives/screen_header.dart';
import '../../state/last_tx_amount.dart';
import '../../state/recent_amounts.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';

/// Scan QRIS (CPM) flow — Handoff §4.9.
///
/// Three steps: scan → confirm (amount entry) → paid.
/// Capability gate: entry disabled when merchant.capabilities.scan_cpm == false.
/// No payer info shown — intentionally suppressed (see Handoff §4.9 + Spec §2.3).
///
/// Camera permission is handled by MobileScannerController internally; if
/// the user denies permission the [_cameraPermissionDenied] flag is set and
/// an instructive empty-state UI is shown. No manual fallback for CPM
/// (Handoff §9 — "Scan QRIS requires the camera").
enum _CpmStep { scan, confirm, paid }

class ScanQrisScreen extends ConsumerStatefulWidget {
  const ScanQrisScreen({super.key, required this.merchantId});

  final String merchantId;

  @override
  ConsumerState<ScanQrisScreen> createState() => _ScanQrisScreenState();
}

class _ScanQrisScreenState extends ConsumerState<ScanQrisScreen> {
  _CpmStep _step = _CpmStep.scan;
  String _amountStr = '';
  String? _detectedPayload;
  String? _idempotencyKey;
  String? _txnRef;
  bool _loading = false;
  String? _error;

  // Flash state for camera
  bool _torchOn = false;

  // Whether the user has denied camera permission
  bool _cameraPermissionDenied = false;

  // Camera controller (only alive during scan step)
  MobileScannerController? _scannerCtrl;

  int get _amount => int.tryParse(_amountStr) ?? 0;
  bool get _canCharge => _amount >= 1000;

  @override
  void initState() {
    super.initState();
    _startScanner();
  }

  @override
  void dispose() {
    _scannerCtrl?.dispose();
    super.dispose();
  }

  void _startScanner() {
    _scannerCtrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
    if (mounted) setState(() {});
  }

  /// Called when MobileScanner encounters an error (including permission denied).
  Widget _onScannerError(BuildContext ctx, MobileScannerException error) {
    final isDenied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    if (isDenied && !_cameraPermissionDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _cameraPermissionDenied = true);
      });
    }
    return ColoredBox(
      color: const Color(0xFF0E0A09),
      child: Center(
        child: isDenied
            ? const CameraIcon(color: Colors.white54, size: 48)
            : const Icon(Icons.error_outline, color: Colors.white54, size: 48),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Haptic feedback on detect
    HapticFeedback.lightImpact();

    _scannerCtrl?.stop();

    setState(() {
      _detectedPayload = raw;
      _step = _CpmStep.confirm;
    });
  }

  void _toggleTorch() {
    _scannerCtrl?.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  void _backToScan() {
    setState(() {
      _step = _CpmStep.scan;
      _amountStr = '';
      _error = null;
      _idempotencyKey = null;
    });
    _scannerCtrl?.start();
  }

  // ─── Charge ────────────────────────────────────────────────────────────────

  Future<void> _charge() async {
    if (!_canCharge || _loading) return;

    // Generate idempotency key once per gesture; reuse on retry
    _idempotencyKey ??= const Uuid().v4();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = await ref.read(dioProvider.future);
      final result = await MerchantsApi(dio).scan(
        widget.merchantId,
        qrPayload: _detectedPayload ?? '',
        amount: _amount,
        idempotencyKey: _idempotencyKey!,
      );

      final txn = result['transaction'] as Map<String, dynamic>?;
      final ref_ = txn?['ref'] as String?;

      // Push amount to recents and record as last transaction amount
      await ref
          .read(recentAmountsProvider((widget.merchantId, 'cpm')).notifier)
          .push(_amount);
      await ref
          .read(lastTxAmountProvider(widget.merchantId).notifier)
          .setLast(_amount);

      // Announce payment via TTS
      // Note: payment_announcer.dart handles this via WS event; no direct call needed here
      // The WS txn.paid event will arrive and trigger the announcer

      setState(() {
        _txnRef = ref_;
        _loading = false;
        _idempotencyKey = null; // discard on success
        _step = _CpmStep.paid;
      });

      _scannerCtrl?.dispose();
      _scannerCtrl = null;
    } on Object catch (e) {
      // 403 capability_disabled → bounce back to merchant dashboard (Handoff §9)
      if (_isCapabilityDisabled(e)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppL10n.of(context).cpmFailed)),
          );
          context.go('/dashboard/merchant/${widget.merchantId}');
        }
        return;
      }
      setState(() {
        _loading = false;
        _error = _extractError(e);
        // Keep _idempotencyKey so retry reuses it
      });
    }
  }

  bool _isCapabilityDisabled(Object e) {
    return e.toString().contains('capability_disabled') ||
        e.toString().contains('403');
  }

  String _extractError(Object e) {
    final s = e.toString();
    if (s.contains('wrong_mode')) return 'wrong_mode';
    if (s.contains('invalid_qr')) return 'invalid_qr';
    if (s.contains('issuer_unsupported')) return 'issuer_unsupported';
    if (s.contains('amount_too_high')) return 'amount_too_high';
    if (s.contains('amount_too_low')) return 'amount_too_low';
    if (s.contains('acquirer_unreachable')) return 'acquirer_unreachable';
    return s;
  }

  // ─── Keypad handlers ───────────────────────────────────────────────────────

  void _onDigit(String d) {
    setState(() {
      if (_amountStr.isEmpty && d == '0') return;
      final raw = (_amountStr + d).replaceFirst(RegExp(r'^0+'), '');
      if (raw.length > 10) return; // cap at 10 digits
      _amountStr = raw;
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
      final raw = ('${_amountStr}000').replaceFirst(RegExp(r'^0+'), '');
      if (raw.length > 10) return;
      _amountStr = raw;
    });
  }

  void _clearAmount() => setState(() => _amountStr = '');

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final merchant = ref
        .watch(sessionProvider)
        .value
        ?.merchants
        .where((m) => m.id == widget.merchantId)
        .firstOrNull;

    // Capability gate — client-side bounce if session already loaded
    // Server-side gate is the authoritative check (403 on _charge)
    if (merchant != null && !merchant.capabilities.scanCpm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/dashboard/merchant/${widget.merchantId}');
      });
    }

    return switch (_step) {
      _CpmStep.scan => _buildScanStep(context, merchant),
      _CpmStep.confirm => _buildConfirmStep(context, merchant),
      _CpmStep.paid => _buildPaidStep(context, merchant),
    };
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Step 1: Camera viewfinder
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildScanStep(BuildContext context, Merchant? merchant) {
    final t = AppL10n.of(context);

    // No camera permission — CPM has no manual fallback (Handoff §9)
    if (_cameraPermissionDenied) {
      return _NoPermissionView(merchantId: widget.merchantId);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0A09),
      body: Stack(
        children: [
          // Live camera feed
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerCtrl!,
              onDetect: _onDetect,
              errorBuilder: _onScannerError,
            ),
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _GlassButton(
                    iconWidget: const CloseIcon(color: Colors.white, size: 18),
                    onTap: () =>
                        context.go('/dashboard/merchant/${widget.merchantId}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.cpmHeader,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.accent,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          merchant?.name ?? '',
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _GlassButton(
                    iconWidget: FlashIcon(
                      color: _torchOn ? AppTokens.accent : Colors.white,
                      size: 18,
                    ),
                    onTap: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),

          // Viewfinder + brackets + scanline
          Center(child: _ViewfinderOverlay()),

          // Instruction text below viewfinder
          Positioned(
            left: 0,
            right: 0,
            bottom: 180,
            child: Column(
              children: [
                Text(
                  t.cpmPointAt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    t.cpmPointAtSub,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 13,
                      color: Color(0xA6FFFFFF),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom action card — the real trigger is onDetect from the camera.
          // This card is decorative only (shows the flow is active).
          Positioned(
            left: 12,
            right: 12,
            bottom: 28 + MediaQuery.of(context).padding.bottom,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTokens.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                t.cpmPointAt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.inkSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Step 2: Confirm — amount entry
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildConfirmStep(BuildContext context, Merchant? merchant) {
    final t = AppL10n.of(context);
    final fmt = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: Column(
        children: [
          // Status bar padding
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _backToScan,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTokens.border.withValues(alpha: 1),
                          spreadRadius: 1,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTokens.ink,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.cpmScanLabel(merchant?.name ?? ''),
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.inkTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.cpmAmountChargeTitle,
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QRIS valid pill
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.successSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppTokens.success,
                                shape: BoxShape.circle,
                              ),
                              child: const CheckIcon(
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.cpmValid,
                              style: const TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.success,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1, 1),
                        duration: 200.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 12),

                  // Amount card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A1A0F0C),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                        BoxShadow(
                          color: Color(0x0D1A0F0C),
                          spreadRadius: 1,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.qrisAmount.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.inkTertiary,
                                letterSpacing: 1,
                              ),
                            ),
                            if (_amountStr.isNotEmpty)
                              GestureDetector(
                                onTap: _clearAmount,
                                child: Container(
                                  height: 24,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.surfaceAlt,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
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
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              t.commonCurrency,
                              style: const TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.inkTertiary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _amountStr.isNotEmpty ? fmt.format(_amount) : '0',
                              style: TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: _amountStr.isNotEmpty
                                    ? AppTokens.ink
                                    : AppTokens.inkDisabled,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Fixed preset chips — always 5K/10K/25K/50K/100K (JSX spec)
                  _ScanPresetRow(
                    onTap: (v) => setState(() => _amountStr = v.toString()),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTokens.dangerSoft,
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTokens.danger,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 13,
                                color: AppTokens.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Keypad + CTA
          _AmountKeypad(
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onTripleZero: _onTripleZero,
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: AppButton(
              label: _canCharge
                  ? t.cpmChargeWithAmount(fmt.format(_amount))
                  : t.cpmCharge,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.lg,
              block: true,
              disabled: !_canCharge || _loading,
              onPressed: _charge,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Step 3: Paid — success
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildPaidStep(BuildContext context, Merchant? merchant) {
    final t = AppL10n.of(context);
    final fmt = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Paprika-pop checkmark
                  Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          color: AppTokens.successSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const CheckIcon(
                          color: AppTokens.success,
                          size: 42,
                        ),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 320.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 160.ms),

                  const SizedBox(height: 18),

                  Text(
                    t.cpmSuccessReceived.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.success,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${t.commonCurrency} ',
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTokens.inkTertiary,
                        ),
                      ),
                      Text(
                        fmt.format(_amount),
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.ink,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Detail card — Method / Merchant / Reference only (no payer info)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTokens.border),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: t.cpmRowMethod,
                            value: t.cpmSuccessMethod,
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTokens.border,
                          ),
                          _DetailRow(
                            label: t.cpmRowMerchant,
                            value: merchant?.name ?? '',
                          ),
                          if (_txnRef != null) ...[
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppTokens.border,
                            ),
                            _DetailRow(
                              label: t.cpmRowRef,
                              value: _txnRef!,
                              mono: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CTA buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  AppButton(
                    label: t.cpmDone,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.lg,
                    block: true,
                    onPressed: () =>
                        context.go('/dashboard/merchant/${widget.merchantId}'),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: t.cpmScanAnother,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.lg,
                    block: true,
                    onPressed: () {
                      setState(() {
                        _step = _CpmStep.scan;
                        _amountStr = '';
                        _detectedPayload = null;
                        _txnRef = null;
                        _idempotencyKey = null;
                        _error = null;
                      });
                      _startScanner();
                    },
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

// ─────────────────────────────────────────────────────────────────────────────
// Camera viewfinder overlay — corner brackets + animated scanline
// ─────────────────────────────────────────────────────────────────────────────

class _ViewfinderOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const framePad = 36.0;
    final size = MediaQuery.of(context).size;
    final viewfinderSize = size.width - framePad * 2;

    return SizedBox(
      width: viewfinderSize,
      height: viewfinderSize,
      child: Stack(
        children: [
          // Semi-transparent black frame (the "mask" around viewfinder)
          Positioned.fill(
            child: CustomPaint(painter: _ViewfinderMaskPainter()),
          ),

          // Corner brackets
          const Positioned(
            top: 0,
            left: 0,
            child: _CornerBracket(corner: _Corner.topLeft),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: _CornerBracket(corner: _Corner.topRight),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            child: _CornerBracket(corner: _Corner.bottomLeft),
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: _CornerBracket(corner: _Corner.bottomRight),
          ),

          // Animated scanline
          Positioned(left: 18, right: 18, child: _ScanLine()),
        ],
      ),
    );
  }
}

class _ViewfinderMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x00000000);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.corner});

  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(painter: _CornerPainter(corner)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.corner);

  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const r = 18.0;
    final w = size.width;
    final h = size.height;

    switch (corner) {
      case _Corner.topLeft:
        canvas.drawLine(Offset(r, 0), const Offset(0, 0), paint);
        canvas.drawLine(const Offset(0, 0), Offset(0, r), paint);
      case _Corner.topRight:
        canvas.drawLine(Offset(w - r, 0), Offset(w, 0), paint);
        canvas.drawLine(Offset(w, 0), Offset(w, r), paint);
      case _Corner.bottomLeft:
        canvas.drawLine(Offset(0, h - r), Offset(0, h), paint);
        canvas.drawLine(Offset(0, h), Offset(r, h), paint);
      case _Corner.bottomRight:
        canvas.drawLine(Offset(w, h - r), Offset(w, h), paint);
        canvas.drawLine(Offset(w, h), Offset(w - r, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppTokens.accent,
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTokens.accent.withValues(alpha: 0.6),
                blurRadius: 16,
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: 200, duration: 1600.ms, curve: Curves.easeInOut)
        .then()
        .moveY(begin: 200, end: 0, duration: 1600.ms, curve: Curves.easeInOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass-style circular button for dark overlay
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.iconWidget, this.onTap});

  final Widget iconWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0x1AFFFFFF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: iconWidget,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No camera permission — instructive empty state (CPM has no manual fallback)
// Handoff §9: "Scan QRIS requires the camera — no manual fallback".
// The user is shown instructions to enable camera in device Settings.
// The "Open Settings" action requires a platform-specific deep-link
// (listed as a runtime handoff item).
// ─────────────────────────────────────────────────────────────────────────────

class _NoPermissionView extends StatelessWidget {
  const _NoPermissionView({required this.merchantId});

  final String merchantId;

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Column(
          children: [
            PaprikaScreenHeader(
              onBack: () => context.go('/dashboard/merchant/$merchantId'),
              title: Text(t.cpmTitle),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTokens.surfaceAlt,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: const CameraIcon(
                        color: AppTokens.inkSecondary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.scanPermissionCta,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: t.scanOpenSettings,
                      variant: AppButtonVariant.primary,
                      onPressed: _openAppSettings,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAppSettings() async {
    final uri = Platform.isIOS
        ? Uri.parse('app-settings:')
        : Uri.parse('package:com.paprika.paprika_merchant');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fixed preset chips — 5K / 10K / 25K / 50K / 100K
// ─────────────────────────────────────────────────────────────────────────────

const _kPresets = [5000, 10000, 25000, 50000, 100000];

class _ScanPresetRow extends StatelessWidget {
  const _ScanPresetRow({required this.onTap});
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
            child: GestureDetector(
              onTap: () => onTap(v),
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
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Amount keypad — 3×4 grid matching Dynamic QRIS keypad layout
// ─────────────────────────────────────────────────────────────────────────────

class _AmountKeypad extends StatelessWidget {
  const _AmountKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onTripleZero,
  });

  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onTripleZero;

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', '⌫'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 56,
        crossAxisSpacing: 8,
        mainAxisSpacing: 4,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        final isBackspace = key == '⌫';
        final isTripleZero = key == '000';

        return GestureDetector(
          onTap: () {
            if (isBackspace) {
              onBackspace();
            } else if (isTripleZero) {
              onTripleZero();
            } else {
              onDigit(key);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            alignment: Alignment.center,
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppTokens.ink,
                    size: 20,
                  )
                : Text(
                    key,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.ink,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row for success screen
// ─────────────────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 13,
              color: AppTokens.inkSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: mono ? AppTokens.fontMono : AppTokens.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}
