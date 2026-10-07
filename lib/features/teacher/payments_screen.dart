import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/parent_records.dart';
import '../../data/models/teacher_records.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'payment_sheet.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// «To'lovlar»: one month at a time — totals, debtors filter, and a row per
/// active student to mark paid/unpaid (same rules as the web panel).
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool _debtorsOnly = false;

  Future<void> _refresh() async {
    ref
      ..invalidate(paymentsProvider)
      ..invalidate(studentsProvider);
    await ref.read(paymentsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final period = ref.watch(selectedPeriodProvider);
    final students = ref.watch(studentsProvider);
    final payments = ref.watch(paymentsProvider);
    final year = int.parse(period.substring(0, 4));
    final month = int.parse(period.substring(5, 7));

    final data = switch ((students, payments)) {
      (AsyncData(value: final s), AsyncData(value: final p)) => AsyncData((
        s,
        p,
      )),
      (AsyncError(:final error, :final stackTrace), _) ||
      (
        _,
        AsyncError(:final error, :final stackTrace),
      ) => AsyncError<(List<Person>, List<Payment>)>(error, stackTrace),
      _ => const AsyncLoading<(List<Person>, List<Payment>)>(),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherTabHeader(title: l10n.navPayments),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('prev_month'),
                    tooltip: l10n.prevMonth,
                    icon: const Icon(LucideIcons.chevronLeft),
                    onPressed: () =>
                        ref.read(selectedPeriodProvider.notifier).shift(-1),
                  ),
                  Expanded(
                    child: Text(
                      formatPeriod(context, year, month),
                      textAlign: TextAlign.center,
                      style: AppText.heading.copyWith(color: colors.ink),
                    ),
                  ),
                  IconButton(
                    key: const Key('next_month'),
                    tooltip: l10n.nextMonth,
                    icon: const Icon(LucideIcons.chevronRight),
                    onPressed: () =>
                        ref.read(selectedPeriodProvider.notifier).shift(1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: data,
                onRetry: _refresh,
                builder: (d) {
                  final (list, rows) = d;
                  if (list.isEmpty) {
                    return MessageView(
                      icon: LucideIcons.users,
                      title: l10n.noStudentsTitle,
                      message: l10n.noStudentsBody,
                    );
                  }
                  final lines = paymentLinesFor(list, rows, period);
                  final expected = lines.fold<num>(
                    0,
                    (s, e) => s + (e.amount ?? 0),
                  );
                  final collected = lines
                      .where((e) => !e.isDebt)
                      .fold<num>(0, (s, e) => s + (e.amount ?? 0));
                  final debtors = lines.where((e) => e.isDebt).length;
                  final visible = _debtorsOnly
                      ? lines.where((e) => e.isDebt).toList()
                      : lines;
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.s5,
                        AppSpace.s2,
                        AppSpace.s5,
                        AppSpace.s8,
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatTile(
                                value: formatAmount(expected),
                                label: l10n.statExpected,
                                color: colors.ink,
                              ),
                            ),
                            const SizedBox(width: AppSpace.s2),
                            Expanded(
                              child: StatTile(
                                value: formatAmount(collected),
                                label: l10n.statCollected,
                                color: colors.success,
                              ),
                            ),
                            const SizedBox(width: AppSpace.s2),
                            Expanded(
                              child: StatTile(
                                value: '$debtors',
                                label: l10n.statDebtors,
                                color: debtors > 0 ? colors.danger : colors.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.s3),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FilterChip(
                            key: const Key('debtors_only'),
                            label: Text(l10n.debtorsOnly),
                            selected: _debtorsOnly,
                            onSelected: (v) => setState(() => _debtorsOnly = v),
                          ),
                        ),
                        const SizedBox(height: AppSpace.s3),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppSpace.s6),
                            child: Text(
                              l10n.noDebtors,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                          ),
                        for (final line in visible) ...[
                          _PaymentRow(line: line, period: period),
                          const SizedBox(height: AppSpace.s2),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.line, required this.period});

  final PaymentLine line;
  final String period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final saved = line.saved;
    return Panel(
      key: Key('payment_${line.student.id}'),
      onTap: () => showPaymentSheet(
        context,
        student: line.student,
        period: period,
        amount: line.amount,
        status: saved?.status ?? PaymentStatus.paid,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s3,
      ),
      child: Row(
        children: [
          PersonAvatar(person: line.student),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.student.fullName,
                  style: AppText.bodyStrong.copyWith(color: colors.ink),
                ),
                Text(
                  line.amount == null
                      ? l10n.amountNotSet
                      : formatMoney(context, line.amount!),
                  style: AppText.caption.copyWith(color: colors.inkMuted),
                ),
              ],
            ),
          ),
          if (saved == null)
            StatusChip(label: l10n.paymentNotMarked, color: colors.inkMuted)
          else
            StatusChip(
              label: saved.status == PaymentStatus.paid
                  ? l10n.paymentPaid
                  : l10n.paymentUnpaid,
              color: saved.status == PaymentStatus.paid
                  ? colors.success
                  : colors.danger,
            ),
        ],
      ),
    );
  }
}
