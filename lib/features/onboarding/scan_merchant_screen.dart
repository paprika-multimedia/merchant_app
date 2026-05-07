import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../net/dio_client.dart';
import '../../net/api/merchants_api.dart';
import '../../primitives/button.dart';
import '../../primitives/icons.dart';
import '../../state/session.dart';
import '../../state/active_merchant.dart';
import '../../theme/tokens.dart';
import '_scanner_overlay.dart';

/// Scan Merchant QR screen — Handoff §4.2.
///
/// [addMode] true: mid-session add → success goes to new merchant dashboard.
/// [addMode] false: first-run onboarding → success goes to company dashboard.
///
/// Bottom sheet: white rounded card (borderRadius 26) containing:
///   - Confirmed-company chip (successSoft bg, CheckIcon, overline + company name)
///   - 3-col SmallAction row (Torch / Gallery / Keyboard)
///   - Primary "Select image" button
/// Matches screens-onboarding.jsx ScreenScanMerchant.
class ScanMerchantScreen extends ConsumerStatefulWidget {
  const ScanMerchantScreen({super.key, this.addMode = false});

  final bool addMode;

  @override
  ConsumerState<ScanMerchantScreen> createState() => _ScanMerchantScreenState();
}

class _ScanMerchantScreenState extends ConsumerState<ScanMerchantScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _detected = false;
  String? _error;
  DateTime? _lastInvalidToast;

  static final _merchantRe = RegExp(
    r'paprika://merchant/([A-Za-z0-9]+)',
    caseSensitive: false,
  );

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_detected) return;
    String? sawAnyQr;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue ?? '';
      if (raw.isEmpty) continue;
      sawAnyQr = raw;
      final match = _merchantRe.firstMatch(raw);
      if (match != null) {
        _detected = true;
        HapticFeedback.mediumImpact();
        final code = match.group(1)!.toUpperCase();
        await _claimMerchant(code);
        return;
      }
    }
    if (sawAnyQr != null) {
      _showInvalidQrToast();
    }
  }

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

  Future<void> _claimMerchant(String code) async {
    setState(() => _error = null);
    try {
      final dio = await ref.read(dioProvider.future);
      final merchant = await MerchantsApi(
        dio,
      ).claim(code, idempotencyKey: const Uuid().v4());
      final session = ref.read(sessionProvider).value;
      if (session != null) {
        final updated = [...session.merchants, merchant];
        ref.read(sessionProvider.notifier).updateMerchants(updated);
      }
      await ref.read(activeMerchantIdProvider.notifier).setActive(merchant.id);

      if (!mounted) return;
      if (widget.addMode) {
        context.go('/dashboard/merchant/${merchant.id}');
      } else {
        context.go('/dashboard/company');
      }
    } catch (e) {
      setState(() {
        _detected = false;
        _error = e.toString();
      });
    }
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
      await _onDetect(capture);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.scanImageNoQr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final session = ref.watch(sessionProvider).value;
    final company = session?.company;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(controller: _scanner, onDetect: _onDetect),
          ),
          ScannerOverlay(
            title: t.scanMerchantTitle,
            subtitle: t.scanMerchantSub,
          ),

          // Error banner
          if (_error != null)
            Positioned(
              top: 80,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTokens.dangerSoft,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppTokens.danger, fontSize: 13),
                ),
              ),
            ),

          // Top buttons (Back + Close), matching JSX
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: Row(
                  children: [
                    _CircleBtn(
                      onTap: () => context.pop(),
                      child: const BackIcon(size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    _CircleBtn(
                      onTap: () => widget.addMode
                          ? context.go('/dashboard/company')
                          : context.go('/welcome'),
                      child: const CloseIcon(size: 18, color: Colors.white),
                    ),
                  ],
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
                  // Confirmed-company chip (only on Scan Merchant)
                  if (company != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.successSoft,
                          borderRadius: BorderRadius.circular(
                            AppTokens.radiusSm,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Green check circle
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppTokens.success,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const CheckIcon(
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Overline + company name
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
                          ],
                        ),
                      ),
                    ),

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
                          onTap: () => context.pushReplacement(
                            '/code/merchant',
                            extra: {'addMode': widget.addMode},
                          ),
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
        decoration: const BoxDecoration(
          color: Color(0x29FFFFFF),
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
