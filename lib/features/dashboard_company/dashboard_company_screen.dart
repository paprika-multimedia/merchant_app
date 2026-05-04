import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/merchant.dart';
import '../../primitives/card.dart';
import '../../primitives/chip.dart';
import '../../primitives/icons.dart';
import '../../primitives/merchant_avatar.dart';
import '../../state/session.dart';
import '../../state/active_merchant.dart';
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
                        // Company pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTokens.accent,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSm),
                          ),
                          child: Text(
                            company.name,
                            style: const TextStyle(
                              fontFamily: AppTokens.fontDisplay,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Settings
                        IconButton(
                          icon: const SettingsIcon(
                            size: 20,
                            color: AppTokens.inkSecondary,
                          ),
                          onPressed: () => showModalBottomSheet(
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
                          tooltip: t.settingsTitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Merchant strip
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final m in merchants) _MerchantChip(merchant: m),
                      // Add chip
                      GestureDetector(
                        onTap: () => context.push('/add-merchant'),
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 8, top: 8, bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTokens.border,
                              style: BorderStyle.solid,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSm),
                          ),
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

              // Fix 6b — notifications promo card
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: wire to notification permission
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppTokens.sp16),
                      decoration: BoxDecoration(
                        color: AppTokens.accentWash,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusLg),
                        border: Border.all(color: AppTokens.accentSoft),
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

              const SliverPadding(
                  padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        );
      },
    );
  }
}

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
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTokens.accent : AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
            color: active ? AppTokens.accent : AppTokens.border,
          ),
        ),
        child: Text(
          merchant.name,
          style: TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppTokens.ink,
          ),
        ),
      ),
    );
  }
}

class _MerchantRow extends StatelessWidget {
  const _MerchantRow({required this.merchant});
  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/dashboard/merchant/${merchant.id}'),
      child: AppCard(
        padding: AppTokens.sp14,
        child: Row(
          children: [
            MerchantAvatar(name: merchant.name, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'IDR ${NumberFormat('#,###', 'id_ID').format(merchant.todayTotal)}',
                    style: const TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 13,
                      color: AppTokens.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (merchant.unreadCount > 0)
              AppChip(
                label: '${merchant.unreadCount}',
                tone: ChipTone.accent,
                leading: const Icon(Icons.circle, size: 6),
              ),
            const ChevronIcon(
              color: AppTokens.inkDisabled,
              size: 20,
            ),
          ],
        ),
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
