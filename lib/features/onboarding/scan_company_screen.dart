import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../../primitives/button.dart';
import '../../primitives/icons.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';
import '_scanner_overlay.dart';

/// Scan Company QR screen — Handoff §4.2.
///
/// Detects any QR with payload matching `paprika://company/<CODE>`.
/// On match: vibrate and navigate to scan/merchant.
///
/// Bottom-sheet chrome: white rounded card (borderRadius 26, T.surface,
/// drop shadow, left 12 / right 12 / bottom 34) containing a 3-col
/// SmallAction row (Torch / Gallery / Keyboard) and a primary "Select image"
/// button. Matches screens-onboarding.jsx ScreenScanCompany.
class ScanCompanyScreen extends ConsumerStatefulWidget {
  const ScanCompanyScreen({super.key});

  @override
  ConsumerState<ScanCompanyScreen> createState() => _ScanCompanyScreenState();
}

class _ScanCompanyScreenState extends ConsumerState<ScanCompanyScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _detected = false;
  DateTime? _lastInvalidToast;

  static final _companyRe = RegExp(
    r'paprika://company/([A-Za-z0-9]+)',
    caseSensitive: false,
  );

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    String? sawAnyQr;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue ?? '';
      if (raw.isEmpty) continue;
      sawAnyQr = raw;
      final match = _companyRe.firstMatch(raw);
      if (match != null) {
        _detected = true;
        HapticFeedback.mediumImpact();
        final code = match.group(1)!.toUpperCase();
        unawaited(_claimAndContinue(code));
        return;
      }
    }
    if (sawAnyQr != null) {
      _showInvalidQrToast();
    }
  }

  /// Claims the company and advances to the merchant-scan step.
  ///
  /// The QR-scan path previously pushed `/scan/merchant` with the company
  /// code in `extra`, but the merchant screen never read it — the company
  /// was never claimed and `sessionProvider` stayed null, leaving the user
  /// to be redirected back to /welcome by the router guard.
  Future<void> _claimAndContinue(String code) async {
    try {
      await ref
          .read(sessionProvider.notifier)
          .claim(companyCode: code);
      if (!mounted) return;
      context.push('/scan/merchant');
    } catch (e) {
      if (!mounted) return;
      _detected = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  /// Show "not a Paprika company QR" feedback, throttled to once every 2s
  /// so a steadily-pointed unrecognized QR doesn't spam the snackbar queue.
  void _showInvalidQrToast() {
    final now = DateTime.now();
    if (_lastInvalidToast != null &&
        now.difference(_lastInvalidToast!) < const Duration(seconds: 2)) {
      return;
    }
    _lastInvalidToast = now;
    HapticFeedback.lightImpact();
    if (!mounted) return;
    final t = AppL10n.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.scanImageNoQr),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Opens image picker, analyzes image for QR, dispatches on match.
  Future<void> _pickAndScanImage() async {
    final t = AppL10n.of(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // analyzeImage returns BarcodeCapture? — null means no barcode found
    final capture = await _scanner.analyzeImage(picked.path);
    if (capture != null && capture.barcodes.isNotEmpty) {
      _onDetect(capture);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.scanImageNoQr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(controller: _scanner, onDetect: _onDetect),
          ),
          ScannerOverlay(title: t.scanCompanyTitle, subtitle: t.scanCompanySub),

          // Close button (top-right), matching JSX CircleBtn
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: _CircleBtn(
                  onTap: () => context.pop(),
                  child: const CloseIcon(size: 18, color: Colors.white),
                ),
              ),
            ),
          ),

          // Bottom sheet chrome — white card, borderRadius 26, l/r 12, bottom 34
          Positioned(
            left: 12,
            right: 12,
            bottom: 34,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTokens.surface,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3-column SmallAction row: Torch / Gallery / Keyboard
                  Row(
                    children: [
                      Expanded(
                        child: _SmallAction(
                          icon: const FlashIcon(size: 18, color: AppTokens.ink),
                          label: t.scanTorch,
                          onTap: () => _scanner.toggleTorch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallAction(
                          icon: const GalleryIcon(
                            size: 18,
                            color: AppTokens.ink,
                          ),
                          label: t.scanGallery,
                          onTap: _pickAndScanImage,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SmallAction(
                          icon: const KeyboardIcon(
                            size: 18,
                            color: AppTokens.ink,
                          ),
                          label: t.welcomeCode,
                          onTap: () => context.pushReplacement('/code/company'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Primary button: Select image (also triggers gallery)
                  AppButton(
                    label: t.scanSelectImage,
                    variant: AppButtonVariant.primary,
                    block: true,
                    onPressed: _pickAndScanImage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared bottom-sheet primitives ──────────────────────────────────────────

/// Glass circle button for camera overlay top bar (matches JSX CircleBtn).
class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0x29FFFFFF), // rgba(255,255,255,0.16)
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// 56px-tall surfaceAlt tile with icon above label — matches JSX SmallAction.
class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: 0.8, child: icon),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTokens.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
