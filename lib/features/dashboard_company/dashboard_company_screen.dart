import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/merchant.dart';
import '../../primitives/card.dart';
import '../../primitives/icons.dart';
import '../../primitives/merchant_avatar.dart';
import '../../state/active_merchant.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';
import '../settings_sheet/settings_sheet.dart';

/// Company Dashboard — Handoff §4.4.
class DashboardCompanyScreen extends ConsumerWidget {
  const DashboardCompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppL10n.of(context);
    final session = ref.watch(sessionProvider);

    return session.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(e.toString())),
      ),
      data: (data) {
        if (data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/welcome');
          });
          return const Scaffold();
        }

        final company = data.company;
        final merchants = data.merchants;

        // Aggregates
        final todayTotal = merchants.fold(0, (s, m) => s + m.todayTotal);
        final todayCount = merchants.fold(0, (s, m) => s + m.todayCount);
        final unreadCount = merchants.fold(0, (s, m) => s + m.unreadCount);

        return Scaffold(
          backgroundColor: AppTokens.bg,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        // Company header bar — 40px, accent bg, Store icon + overline + name
                        Expanded(
                          child: _CompanyHeaderBar(
                            companyName: company.name,
                            label: t.codeCompanyLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Settings button — 40×40, surface bg, border
                        GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(AppTokens.radius2xl),
                              ),
                            ),
                            builder: (_) => const SettingsSheet(),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTokens.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusSm),
                              border: Border.all(color: AppTokens.border),
                            ),
                            alignment: Alignment.center,
                            child: const SettingsIcon(
                              size: 18,
                              color: AppTokens.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Merchant strip — 40px pills with avatars
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    children: [
                      for (final m in merchants) _MerchantChip(merchant: m),
                      // Add chip
                      GestureDetector(
                        onTap: () => context.push('/add-merchant'),
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTokens.border),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const PlusIcon(
                              size: 18, color: AppTokens.inkSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero card
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    color: AppTokens.accent,
                    padding: AppTokens.sp22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.dashCompanyToday,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'IDR ${NumberFormat('#,###', 'id_ID').format(todayTotal)}',
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _StatPill(
                                label: t.dashCompanyStatMerchants,
                                value: '${merchants.length}'),
                            const SizedBox(width: 8),
                            _StatPill(
                                label: t.dashCompanyStatTxns,
                                value: '$todayCount'),
                            const SizedBox(width: 8),
                            if (unreadCount > 0)
                              _StatPill(
                                  label: t.dashCompanyStatUnread,
                                  value: '$unreadCount'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Merchant list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    t.dashCompanyList,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.inkSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              if (merchants.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () => context.push('/add-merchant'),
                      child: AppCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              t.dashCompanyAdd,
                              style: const TextStyle(
                                fontFamily: AppTokens.fontDisplay,
                                fontSize: 15,
                                color: AppTokens.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final m = merchants[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _MerchantRow(merchant: m),
                      );
                    },
                    childCount: merchants.length,
                  ),
                ),

              // Notifications promo card with dashed border (M12)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: wire to notification permission
                    },
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        radius: AppTokens.radiusLg,
                        color: AppTokens.accentSoft,
                      ),
                      child: Container(
                      padding: const EdgeInsets.all(AppTokens.sp16),
                      decoration: BoxDecoration(
                        color: AppTokens.accentWash,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusLg),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTokens.accentSoft,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.sp10),
                            ),
                            alignment: Alignment.center,
                            child: const BellIcon(
                              size: 18,
                              color: AppTokens.accentDeep,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.dashCompanyNotif,
                                  style: const TextStyle(
                                    fontFamily: AppTokens.fontDisplay,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTokens.accentInk,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.dashCompanyNotifSub,
                                  style: const TextStyle(
                                    fontFamily: AppTokens.fontDisplay,
                                    fontSize: 12,
                                    color: AppTokens.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverPadding(
                  padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        );
      },
    );
  }
}

/// 40px pill with MerchantAvatar(28) + name, active = accent bg + surface text.
class _MerchantChip extends ConsumerWidget {
  const _MerchantChip({required this.merchant});
  final Merchant merchant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeMerchantIdProvider) == merchant.id;
    return GestureDetector(
      onTap: () {
        ref.read(activeMerchantIdProvider.notifier).setActive(merchant.id);
        context.push('/dashboard/merchant/${merchant.id}');
      },
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.only(left: 6, right: 12),
        decoration: BoxDecoration(
          color: active ? AppTokens.accent : AppTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: active ? null : Border.all(color: AppTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MerchantAvatar(
              name: merchant.name,
              size: 28,
              active: active,
            ),
            const SizedBox(width: 8),
            Text(
              merchant.name,
              style: TextStyle(
                fontFamily: AppTokens.fontDisplay,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppTokens.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantRow extends StatelessWidget {
  const _MerchantRow({required this.merchant});
  final Merchant merchant;

  /// Short relative time string from ISO timestamp.
  /// Returns e.g. "2m", "1h", "Yesterday", or "—" if null.
  static String _relativeTime(String? isoAt) {
    if (isoAt == null) return '—';
    final at = DateTime.tryParse(isoAt);
    if (at == null) return '—';
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final timeStr = _relativeTime(merchant.lastTransactionAt);
    final hasLastTx = merchant.lastTransactionAt != null;
    final lastAmount = merchant.lastTransactionAmount;
    final fmt = NumberFormat('#,###', 'id_ID');

    return GestureDetector(
      onTap: () =>
          context.push('/dashboard/merchant/${merchant.id}'),
      child: AppCard(
        padding: AppTokens.sp14,
        child: Row(
          children: [
            MerchantAvatar(name: merchant.name, size: 44),
            const SizedBox(width: 12),
            // Left column: name + #code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    merchant.code.isNotEmpty ? merchant.code : '',
                    style: const TextStyle(
                      fontFamily: AppTokens.fontMono,
                      fontSize: 12,
                      color: AppTokens.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Right column: last · time + amount from backend fields
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hasLastTx
                      ? '${t.txLast} · $timeStr'
                      : t.txNone,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.inkTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lastAmount != null
                      ? 'IDR ${fmt.format(lastAmount)}'
                      : '—',
                  style: TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: hasLastTx
                        ? AppTokens.ink
                        : AppTokens.inkTertiary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const ChevronIcon(
              color: AppTokens.inkTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// 40px full-width header bar: Store icon + "COMPANY" overline + company name.
///
/// Mirrors AppShell header in screens-dashboard.jsx (isCompanyLevel=true state,
/// background: T.accent, color: #fff).
class _CompanyHeaderBar extends StatelessWidget {
  const _CompanyHeaderBar({
    required this.companyName,
    required this.label,
  });

  final String companyName;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTokens.accent,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141A0F0C),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store icon sub-container 26×26
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: const StoreIcon(size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.8,
                    height: 1,
                  ),
                ),
                Text(
                  companyName,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.1,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$value $label',
        style: const TextStyle(
          fontFamily: AppTokens.fontDisplay,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Paints a 1px dashed rounded-rectangle border (dash 4, gap 3).
///
/// Used for the notifications promo card (M12).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashLen = 4.0;
    const gapLen = 3.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );

    // Convert the rounded-rect path to a metric and draw dashes along it
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final segLen = draw ? dashLen : gapLen;
        if (draw) {
          final extracted = metric.extractPath(distance,
              (distance + segLen).clamp(0, metric.length));
          canvas.drawPath(extracted, paint);
        }
        distance += segLen;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
