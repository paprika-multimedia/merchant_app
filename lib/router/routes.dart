import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/scan_company_screen.dart';
import '../features/onboarding/scan_merchant_screen.dart';
import '../features/onboarding/code_screen.dart';
import '../features/dashboard_company/dashboard_company_screen.dart';
import '../features/dashboard_merchant/dashboard_merchant_screen.dart';
import '../features/add_merchant/add_merchant_screen.dart';
import '../features/dynamic_qris/dynamic_qris_screen.dart';
import '../features/payment_link/payment_link_screen.dart';
import '../features/scan_qris/scan_qris_screen.dart';
import '../state/session.dart';

/// All 11 app routes — mirrors Flutter-Implementation.md §15.
///
/// Route names reflect Handoff §4 screen names.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) async {
      final session = ref.read(sessionProvider).value;
      final isOnboarding =
          state.matchedLocation.startsWith('/welcome') ||
          state.matchedLocation.startsWith('/scan/company') ||
          state.matchedLocation.startsWith('/code/company') ||
          state.matchedLocation.startsWith('/scan/merchant') ||
          state.matchedLocation.startsWith('/code/merchant');
      if (session == null && !isOnboarding) return '/Welcome';
      return null;
    },
    routes: [
      // ─── Onboarding ─────────────────────────────────────────────────────────
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(
        path: '/scan/company',
        builder: (_, _) => const ScanCompanyScreen(),
      ),
      GoRoute(
        path: '/code/company',
        builder: (_, _) => const CodeScreen(kind: CodeScreenKind.company),
      ),
      GoRoute(
        path: '/scan/merchant',
        builder: (_, state) {
          final addMode = state.extra is Map
              ? (state.extra as Map)['addMode'] == true
              : false;
          return ScanMerchantScreen(addMode: addMode);
        },
      ),
      GoRoute(
        path: '/code/merchant',
        builder: (_, state) {
          final addMode = state.extra is Map
              ? (state.extra as Map)['addMode'] == true
              : false;
          return CodeScreen(kind: CodeScreenKind.merchant, addMode: addMode);
        },
      ),

      // ─── Dashboards ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard/company',
        builder: (_, _) => const DashboardCompanyScreen(),
      ),
      GoRoute(
        path: '/dashboard/merchant/:id',
        builder: (_, state) =>
            DashboardMerchantScreen(merchantId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/add-merchant',
        builder: (_, _) => const AddMerchantScreen(),
      ),

      // ─── Payment actions ─────────────────────────────────────────────────────
      GoRoute(
        path: '/dynamic-qris',
        redirect: _requireMerchantId,
        builder: (_, state) => DynamicQrisScreen(
          merchantId: (state.extra as Map)['merchantId'] as String,
        ),
      ),
      GoRoute(
        path: '/payment-link',
        redirect: _requireMerchantId,
        builder: (_, state) => PaymentLinkScreen(
          merchantId: (state.extra as Map)['merchantId'] as String,
        ),
      ),
      GoRoute(
        path: '/scan-cpm',
        redirect: _requireMerchantId,
        builder: (_, state) => ScanQrisScreen(
          merchantId: (state.extra as Map)['merchantId'] as String,
        ),
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.error}'))),
  );
});

/// Redirects to the company dashboard if the route was pushed without a
/// `merchantId` in `extra`. Avoids silent coalescing to an empty string,
/// which previously produced `firstWhere`-throws and `/merchants//qris`-style
/// malformed URLs deep inside the payment flows.
String? _requireMerchantId(BuildContext _, GoRouterState state) {
  final extra = state.extra;
  if (extra is! Map) return '/dashboard/company';
  final id = extra['merchantId'];
  if (id is! String || id.isEmpty) return '/dashboard/company';
  return null;
}
