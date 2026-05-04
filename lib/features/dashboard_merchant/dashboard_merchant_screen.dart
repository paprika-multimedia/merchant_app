import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/merchant.dart';
import '../../models/transaction.dart';
import '../../net/api/merchants_api.dart';
import '../../net/dio_client.dart';
import '../../primitives/card.dart';
import '../../primitives/chip.dart';
import '../../primitives/icons.dart';
import '../../primitives/merchant_avatar.dart';
import '../../state/session.dart';
import '../../theme/tokens.dart';
import '../remove_merchant_sheet/remove_merchant_sheet.dart';

/// Merchant Dashboard — Handoff §4.5.
class DashboardMerchantScreen extends ConsumerStatefulWidget {
  const DashboardMerchantScreen({super.key, required this.merchantId});

  final String merchantId;

  @override
  ConsumerState<DashboardMerchantScreen> createState() =>
      _DashboardMerchantScreenState();
}

class _DashboardMerchantScreenState
    extends ConsumerState<DashboardMerchantScreen> {
  List<Transaction> _transactions = [];
  bool _loadingTxns = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _markSeen();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _loadingTxns = true);
    try {
      final dio = await ref.read(dioProvider.future);
      final txns = await MerchantsApi(dio)
          .listTransactions(widget.merchantId, limit: 10);
      if (mounted) setState(() => _transactions = txns);
    } finally {
      if (mounted) setState(() => _loadingTxns = false);
    }
  }

  Future<void> _markSeen() async {
    try {
      final dio = await ref.read(dioProvider.future);
      await MerchantsApi(dio).markSeen(widget.merchantId);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    // Watch session for merchant.updated events
    final merchant = ref.watch(sessionProvider).value?.merchants
        .where((m) => m.id == widget.merchantId)
        .firstOrNull;

    if (merchant == null) {
      return Scaffold(
        body: Center(child: Text(t.commonClose)),
      );
    }

    final fmt = NumberFormat('#,###', 'id_ID');
    final canScan = merchant.capabilities.scanCpm;
    final session = ref.watch(sessionProvider).value;
    final merchants = session?.merchants ?? [];

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    // Company pill
                    GestureDetector(
                      onTap: () => context.go('/dashboard/company'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTokens.accentSoft,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                        child: Text(
                          session?.company.name ?? '',
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.accentDeep,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Merchant options
                    IconButton(
                      icon: const MoreIcon(
                          size: 20, color: AppTokens.inkSecondary),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppTokens.radius2xl)),
                        ),
                        builder: (_) => RemoveMerchantSheet(
                          merchant: merchant,
                          siblingMerchants: merchants
                              .where((m) => m.id != merchant.id)
                              .toList(),
                        ),
                      ),
                      tooltip: t.merchantSettings,
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
                  for (final m in merchants)
                    _MerchantChip(
                      merchant: m,
                      active: m.id == widget.merchantId,
                    ),
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

          // Hero card — "Received today"
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AppCard(
                color: AppTokens.accentWash,
                padding: AppTokens.sp22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.dashMerchantReceived,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.accentDeep,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        AppChip(
                          label: t.dashMerchantLive,
                          tone: ChipTone.success,
                          leading: const _PulseDot(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'IDR ${fmt.format(merchant.todayTotal)}',
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 2-up BigStat grid — transactions + avg ticket
                    Row(
                      children: [
                        Expanded(
                          child: _BigStat(
                            label: t.dashCompanyStatTxns,
                            value: '${merchant.todayCount}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigStat(
                            label: t.dashMerchantAvg,
                            value: merchant.todayCount > 0
                                ? 'IDR ${fmt.format((merchant.todayTotal / merchant.todayCount).round())}'
                                : 'IDR 0',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action tiles
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      label: t.actionQris,
                      sub: t.actionQrisSub,
                      iconWidget: const QrIcon(
                          size: 22, color: AppTokens.accent),
                      accent: true,
                      onTap: () => context.push(
                        '/dynamic-qris',
                        extra: {'merchantId': merchant.id},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionTile(
                      label: t.actionLink,
                      sub: t.actionLinkSub,
                      iconWidget: const LinkIcon(
                          size: 22, color: AppTokens.ink),
                      onTap: () => context.push(
                        '/payment-link',
                        extra: {'merchantId': merchant.id},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionTile(
                      label: t.actionScan,
                      sub: canScan ? t.actionScanSub : t.actionScanDisabled,
                      iconWidget: const CameraIcon(
                          size: 22, color: AppTokens.ink),
                      disabled: !canScan,
                      onTap: canScan
                          ? () => context.push(
                                '/scan-cpm',
                                extra: {'merchantId': merchant.id},
                              )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent activity
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                t.dashMerchantRecent,
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

          if (_loadingTxns)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_transactions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    t.dashMerchantEmpty,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 14,
                      color: AppTokens.inkTertiary,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: AppCard(
                  padding: 0,
                  child: Column(
                    children: [
                      for (int i = 0; i < _transactions.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTokens.border,
                          ),
                        _TxnRow(txn: _transactions[i]),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

/// 40px pill with MerchantAvatar(28) + name, active = accent bg + surface text.
class _MerchantChip extends StatelessWidget {
  const _MerchantChip({required this.merchant, required this.active});
  final Merchant merchant;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/dashboard/merchant/${merchant.id}'),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.only(left: 6, right: 12),
        decoration: BoxDecoration(
          color: active ? AppTokens.accent : AppTokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? null
              : Border.all(color: AppTokens.border),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.sub,
    required this.iconWidget,
    this.accent = false,
    this.disabled = false,
    this.onTap,
  });

  final String label;
  final String sub;
  final Widget iconWidget;
  final bool accent;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent ? AppTokens.accentSoft : AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            border: Border.all(color: AppTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWidget,
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent ? AppTokens.accentDeep : AppTokens.ink,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 11,
                  color: AppTokens.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});
  final Transaction txn;

  /// Short relative time from ISO timestamp (mirrors _MerchantRow._relativeTime).
  static String _relativeTime(String isoAt) {
    final at = DateTime.tryParse(isoAt);
    if (at == null) return '';
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[(at.weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final fmt = NumberFormat('#,###', 'id_ID');
    final timeStr = _relativeTime(txn.createdAt);

    final (tone, statusLabel) = switch (txn.status) {
      TransactionStatus.paid => (ChipTone.success, t.txStatusPaid),
      TransactionStatus.pending => (ChipTone.warning, t.txStatusPending),
      TransactionStatus.failed => (ChipTone.danger, t.txStatusFailed),
      TransactionStatus.expired => (ChipTone.neutral, t.txStatusExpired),
      TransactionStatus.cancelled => (ChipTone.neutral, t.txStatusCancelled),
      TransactionStatus.refunded => (ChipTone.neutral, t.txStatusRefunded),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: const TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr.isNotEmpty
                      ? '$timeStr · #${txn.ref}'
                      : '#${txn.ref}',
                  style: const TextStyle(
                    fontFamily: AppTokens.fontMono,
                    fontSize: 11,
                    color: AppTokens.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'IDR ${fmt.format(txn.amount)}',
                style: const TextStyle(
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.ink,
                ),
              ),
              const SizedBox(height: 4),
              AppChip(
                label: statusLabel,
                tone: tone,
                leading: Icon(
                  tone == ChipTone.success
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined,
                  size: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White tile stat — mirrors BigStat in screens-dashboard.jsx (onAccent=true).
class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTokens.inkTertiary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTokens.ink,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppTokens.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
