import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../primitives/button.dart';
import '_scanner_overlay.dart';

/// Scan Company QR screen — Handoff §4.2.
///
/// Detects any QR with payload matching `paprika://company/<CODE>`.
/// On match: vibrate and navigate to scan/merchant.
class ScanCompanyScreen extends ConsumerStatefulWidget {
  const ScanCompanyScreen({super.key});

  @override
  ConsumerState<ScanCompanyScreen> createState() => _ScanCompanyScreenState();
}

class _ScanCompanyScreenState extends ConsumerState<ScanCompanyScreen> {
  final MobileScannerController _scanner = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue ?? '';
      final match = RegExp(r'paprika://company/([A-Z0-9]+)').firstMatch(raw);
      if (match != null) {
        _detected = true;
        final code = match.group(1)!;
        // Navigate forward carrying the detected code
        context.push('/scan/merchant', extra: {'companyCode': code});
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
          ),
          ScannerOverlay(
            title: t.scanCompanyTitle,
            subtitle: t.scanCompanySub,
          ),
          // Bottom sheet controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.sp22,
                AppTokens.sp16,
                AppTokens.sp22,
                AppTokens.sp28,
              ),
              decoration: const BoxDecoration(
                color: Colors.black54,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Torch toggle
                        _ScannerAction(
                          label: t.scanTorch,
                          icon: Icons.flash_on,
                          onTap: () => _scanner.toggleTorch(),
                        ),
                        const SizedBox(width: AppTokens.sp28),
                        // Gallery picker
                        _ScannerAction(
                          label: t.scanGallery,
                          icon: Icons.photo_library_outlined,
                          onTap: () => _scanner.analyzeImage(''),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.sp16),
                    AppButton(
                      label: t.scanCodeFallback,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.pushReplacement('/code/company'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.sp16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                    tooltip: t.commonBack,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerAction extends StatelessWidget {
  const _ScannerAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: AppTokens.fontDisplay,
            ),
          ),
        ],
      ),
    );
  }
}
