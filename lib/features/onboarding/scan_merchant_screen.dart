import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../net/dio_client.dart';
import '../../net/api/merchants_api.dart';
import '../../state/session.dart';
import '../../state/active_merchant.dart';
import '../../theme/tokens.dart';
import '../../primitives/button.dart';
import '_scanner_overlay.dart';

/// Scan Merchant QR screen — Handoff §4.2.
///
/// [addMode] true: mid-session add → success goes to new merchant dashboard.
/// [addMode] false: first-run onboarding → success goes to company dashboard.
class ScanMerchantScreen extends ConsumerStatefulWidget {
  const ScanMerchantScreen({super.key, this.addMode = false});

  final bool addMode;

  @override
  ConsumerState<ScanMerchantScreen> createState() =>
      _ScanMerchantScreenState();
}

class _ScanMerchantScreenState extends ConsumerState<ScanMerchantScreen> {
  final MobileScannerController _scanner = MobileScannerController();
  bool _detected = false;
  String? _error;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_detected) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue ?? '';
      final match =
          RegExp(r'paprika://merchant/([A-Z0-9]+)').firstMatch(raw);
      if (match != null) {
        _detected = true;
        final code = match.group(1)!;
        await _claimMerchant(code);
        return;
      }
    }
  }

  Future<void> _claimMerchant(String code) async {
    setState(() => _error = null);
    try {
      final dio = await ref.read(dioProvider.future);
      final merchant = await MerchantsApi(dio).claim(
        code,
        idempotencyKey: const Uuid().v4(),
      );
      // Update session with new merchant
      final session = ref.read(sessionProvider).valueOrNull;
      if (session != null) {
        final updated = [...session.merchants, merchant];
        ref.read(sessionProvider.notifier).updateMerchants(updated);
      }
      await ref.read(activeMerchantIdProvider.notifier).setActive(merchant.id);

      if (!mounted) return;
      if (widget.addMode) {
        // Mid-session: go to new merchant dashboard
        context.go('/dashboard/merchant/${merchant.id}');
      } else {
        // First-run: go to company dashboard
        context.go('/dashboard/company');
      }
    } catch (e) {
      setState(() {
        _detected = false;
        _error = e.toString();
      });
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
            title: t.scanMerchantTitle,
            subtitle: t.scanMerchantSub,
          ),
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              color: Colors.black54,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ScanAction(
                          label: t.scanTorch,
                          icon: Icons.flash_on,
                          onTap: () => _scanner.toggleTorch(),
                        ),
                        const SizedBox(width: AppTokens.sp28),
                        _ScanAction(
                          label: t.scanGallery,
                          icon: Icons.photo_library_outlined,
                          onTap: () => _scanner.analyzeImage(''),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: t.scanCodeFallback,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.pushReplacement(
                        '/code/merchant',
                        extra: {'addMode': widget.addMode},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
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

class _ScanAction extends StatelessWidget {
  const _ScanAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: AppTokens.fontDisplay)),
          ],
        ),
      );
}
