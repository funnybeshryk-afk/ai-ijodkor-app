import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/parent_records.dart';
import '../../data/models/student_records.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'parent_providers.dart';

/// Mockup «4 · Ota-ona»: one child's progress, homework, points, payment
/// status by month and a feed of recent events. Deliberately a single,
/// simple scrolling page.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(childrenProvider);
    ref.invalidate(childOverviewProvider);
    await ref.read(childrenProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final children = ref.watch(childrenProvider);
    final many = (children.value?.length ?? 0) > 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s5,
                AppSpace.s5,
                AppSpace.s3,
                0,
              ),
              child: Row(
                children: [
                  const LogoBadge(size: AppSize.logoBadgeSm),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Text(
                      many ? l10n.parentHomeTitle : l10n.parentTitleOne,
                      style: AppText.displaySm.copyWith(
                        color: context.colors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.profileTitle,
                    icon: const Icon(LucideIcons.user),
                    onPressed: () => context.push(Routes.profile),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: children,
                onRetry: () => _refresh(ref),
                loading: const _ParentSkeleton(),
                builder: (list) => list.isEmpty
                    ? MessageView(
                        icon: LucideIcons.users,
                        title: l10n.noChildrenTitle,
                        message: l10n.noChildrenBody,
                      )
                    : RefreshIndicator(
                        onRefresh: () => _refresh(ref),
                        child: _ChildPage(children: list),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildPage extends ConsumerWidget {
  const _ChildPage({required this.children});

  final List<Child> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedChildProvider);
    final child =
        children.where((c) => c.id == selectedId).firstOrNull ?? children.first;
    final overview = ref.watch(childOverviewProvider(child.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s5,
        AppSpace.s5,
        AppSpace.s5,
        AppSpace.s8,
      ),
      children: [
        if (children.length > 1) ...[
          _ChildSwitcher(children: children, selected: child),
          const SizedBox(height: AppSpace.s4),
        ],
        overview.when(
          loading: () => const _OverviewSkeleton(),
          error: (_, _) => Panel(
            child: ErrorRetryView(
              onRetry: () => ref.invalidate(childOverviewProvider(child.id)),
            ),
          ),
          data: (o) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChildCard(child: child, overview: o),
              const SizedBox(height: AppSpace.s5),
              _PaymentSection(child: child, overview: o),
              const SizedBox(height: AppSpace.s5),
              _EventsSection(
                events: buildChildEvents(o, ru: context.contentRu),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pills to switch between several linked children.
class _ChildSwitcher extends ConsumerWidget {
  const _ChildSwitcher({required this.children, required this.selected});

  final List<Child> children;
  final Child selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in children) ...[
            Semantics(
              button: true,
              selected: c.id == selected.id,
              child: GestureDetector(
                key: Key('child_${c.id}'),
                onTap: () =>
                    ref.read(selectedChildProvider.notifier).select(c.id),
                child: Container(
                  height: AppSize.touch,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.id == selected.id
                        ? colors.inverse
                        : colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    c.givenName,
                    style: AppText.labelLg.copyWith(
                      color: c.id == selected.id
                          ? colors.onInverse
                          : colors.inkSoft,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s2),
          ],
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.overview});

  final Child child;
  final ChildOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final o = overview;
    final percent = (o.completion * 100).round();
    return Panel(
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.avatarLg,
                height: AppSize.avatarLg,
                decoration: BoxDecoration(
                  color: colors.brandTint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.brand,
                    width: AppSize.avatarBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  child.givenName.isEmpty
                      ? ''
                      : child.givenName.characters.first.toUpperCase(),
                  style: AppText.displaySm.copyWith(color: colors.brandDeep),
                ),
              ),
              const SizedBox(width: AppSpace.card),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.givenName,
                      style: AppText.heading.copyWith(color: colors.ink),
                    ),
                    Text(
                      l10n.childLessonsOpened(o.lessons.length),
                      style: AppText.labelLg.copyWith(
                        color: colors.inkMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.panel),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l10n.parentProgressTitle,
                  style: AppText.bodyStrong.copyWith(color: colors.ink),
                ),
              ),
              Text(
                l10n.percentValue(percent),
                style: AppText.statValue.copyWith(color: colors.ink),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s2),
          ProgressBar(
            value: o.completion,
            color: colors.brand,
            height: AppSize.progressBarLg,
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            l10n.parentProgressCaption(o.completedCount, o.lessons.length),
            style: AppText.caption.copyWith(
              color: colors.inkSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpace.panel),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  value: '${o.countHomework(HomeworkStatus.approved)}',
                  label: l10n.tileApproved,
                  color: colors.success,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: _Tile(
                  value: '${o.countHomework(HomeworkStatus.pending)}',
                  label: l10n.tilePending,
                  color: colors.brandStrong,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: _Tile(
                  value: o.xp == null ? '…' : formatAmount(o.xp!),
                  label: l10n.tilePoints,
                  color: colors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.tileGap,
        vertical: AppSpace.s3,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Column(
        children: [
          Text(value, style: AppText.heading.copyWith(color: color)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.chip.copyWith(
              color: colors.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// «To'lov»: the month to pay in a dark panel, then the other months.
class _PaymentSection extends ConsumerWidget {
  const _PaymentSection({required this.child, required this.overview});

  final Child child;
  final ChildOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final due = overview.duePayment;
    final others = overview.paymentsByPeriod.where((p) => p != due).take(6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.paymentTitle),
        const SizedBox(height: AppSpace.s2),
        if (overview.payments.isEmpty)
          NotePanel(icon: LucideIcons.wallet, text: l10n.paymentNone)
        else if (due == null)
          NotePanel(icon: LucideIcons.checkCircle, text: l10n.paymentAllPaid)
        else
          _DuePanel(child: child, payment: due),
        for (final p in others)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s4,
              vertical: AppSpace.s3,
            ),
            child: Row(
              children: [
                Icon(
                  p.status == PaymentStatus.paid
                      ? LucideIcons.check
                      : LucideIcons.circleAlert,
                  size: AppSize.iconBtn,
                  color: p.status == PaymentStatus.paid
                      ? colors.success
                      : colors.danger,
                ),
                const SizedBox(width: AppSpace.tileGap),
                Expanded(
                  child: Text(
                    p.status == PaymentStatus.paid
                        ? l10n.paymentRowPaid(
                            formatPeriod(context, p.year, p.month),
                          )
                        : l10n.paymentRowUnpaid(
                            formatPeriod(context, p.year, p.month),
                          ),
                    style: AppText.labelLg.copyWith(color: colors.ink),
                  ),
                ),
                Text(
                  formatMoney(context, p.amount),
                  style: AppText.labelLg.copyWith(
                    color: colors.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DuePanel extends ConsumerWidget {
  const _DuePanel({required this.child, required this.payment});

  final Child child;
  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final links = ref.watch(paymentLinksProvider);

    void pay(String provider) => launchUrl(
      links.paymentUri(
        provider: provider,
        childId: child.id,
        period: payment.period,
      ),
      mode: LaunchMode.externalApplication,
    );

    return Container(
      key: const Key('due_payment'),
      padding: const EdgeInsets.all(AppSpace.panel),
      decoration: BoxDecoration(
        color: colors.inverse,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPeriod(context, payment.year, payment.month),
                  style: AppText.metric.copyWith(
                    color: colors.onInverse,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.tileGap,
                  vertical: AppSpace.s1,
                ),
                decoration: BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  l10n.paymentUnpaid,
                  style: AppText.chip.copyWith(color: colors.onBrand),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.card),
          Text(
            formatMoney(context, payment.amount),
            style: AppText.amount.copyWith(color: colors.onInverse),
          ),
          const SizedBox(height: AppSpace.card),
          if (links.canPayOnline)
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    key: const Key('pay_click'),
                    label: l10n.payClick,
                    height: AppSize.button,
                    onPressed: () => pay('click'),
                  ),
                ),
                const SizedBox(width: AppSpace.tileGap),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('pay_payme'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onInverse,
                      side: BorderSide(
                        color: colors.onInverse,
                        width: AppSize.borderInput,
                      ),
                    ),
                    onPressed: () => pay('payme'),
                    child: Text(l10n.payPayme),
                  ),
                ),
              ],
            )
          else ...[
            Text(
              l10n.paymentContactHint,
              style: AppText.caption.copyWith(
                color: colors.onInverse,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpace.s3),
            PrimaryButton(
              key: const Key('contact_button'),
              label: l10n.contactButton,
              icon: LucideIcons.messageCircle,
              height: AppSize.button,
              onPressed: () => showContactSheet(context, links),
            ),
          ],
        ],
      ),
    );
  }
}

/// Telegram / phone options of the program.
Future<void> showContactSheet(BuildContext context, PaymentLinks links) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s5,
          0,
          AppSpace.s5,
          AppSpace.s5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.contactButton,
              style: AppText.displaySm.copyWith(color: context.colors.ink),
            ),
            const SizedBox(height: AppSpace.s4),
            PrimaryButton(
              key: const Key('contact_telegram'),
              label: l10n.contactTelegram,
              icon: LucideIcons.send,
              height: AppSize.button,
              onPressed: () => launchUrl(
                Uri.parse(links.telegramUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(height: AppSpace.s3),
            OutlinedButton.icon(
              key: const Key('contact_call'),
              icon: const Icon(LucideIcons.phone, size: AppSize.iconBtn),
              label: Text('${l10n.contactCall} · ${links.phone}'),
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: links.phone)),
            ),
          ],
        ),
      ),
    ),
  );
}

/// «So'nggi yangiliklar».
class _EventsSection extends StatelessWidget {
  const _EventsSection({required this.events});

  final List<ChildEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.eventsTitle),
        const SizedBox(height: AppSpace.s1),
        if (events.isEmpty)
          Text(
            l10n.eventsEmpty,
            style: AppText.body.copyWith(color: colors.inkMuted),
          ),
        for (final (i, e) in events.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.tileGap),
            decoration: BoxDecoration(
              border: i == events.length - 1
                  ? null
                  : Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.labelGap),
                  child: Container(
                    width: AppSize.eventDot,
                    height: AppSize.eventDot,
                    decoration: BoxDecoration(
                      color: _dotColor(e, colors),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _title(context, e),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (_subject(context, e).isNotEmpty)
                              TextSpan(text: ' — ${_subject(context, e)}'),
                          ],
                        ),
                        style: AppText.eventLine.copyWith(color: colors.ink),
                      ),
                      Text(
                        formatEventTime(context, e.at),
                        style: AppText.chip.copyWith(
                          color: colors.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Color _dotColor(ChildEvent e, AppColors c) => switch (e.kind) {
    ChildEventKind.homeworkApproved ||
    ChildEventKind.lessonCompleted ||
    ChildEventKind.paymentPaid => c.success,
    ChildEventKind.homeworkRejected => c.danger,
    ChildEventKind.homeworkSubmitted || ChildEventKind.points => c.brand,
  };

  static String _title(BuildContext context, ChildEvent e) {
    final l10n = context.l10n;
    return switch (e.kind) {
      ChildEventKind.homeworkSubmitted => l10n.eventHomeworkSubmitted,
      ChildEventKind.homeworkApproved => l10n.eventHomeworkApproved,
      ChildEventKind.homeworkRejected => l10n.eventHomeworkRejected,
      ChildEventKind.lessonCompleted => l10n.eventLessonCompleted,
      ChildEventKind.points => l10n.eventPoints(
        e.points > 0 ? '+${formatAmount(e.points)}' : formatAmount(e.points),
      ),
      ChildEventKind.paymentPaid => l10n.eventPaymentPaid,
    };
  }

  static String _subject(BuildContext context, ChildEvent e) {
    if (e.kind == ChildEventKind.paymentPaid && e.payment != null) {
      final p = e.payment!;
      return formatPeriod(context, p.year, p.month);
    }
    if (e.subject.isEmpty) return '';
    return e.kind == ChildEventKind.points ? e.subject : '«${e.subject}»';
  }
}

class _ParentSkeleton extends StatelessWidget {
  const _ParentSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppSpace.s5),
    children: const [_OverviewSkeleton()],
  );
}

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SkeletonBox(height: 280, radius: AppRadius.lg),
      SizedBox(height: AppSpace.s5),
      SkeletonBox(height: AppSpace.s6, width: 120),
      SizedBox(height: AppSpace.s2),
      SkeletonBox(height: 180, radius: AppRadius.lg),
      SizedBox(height: AppSpace.s5),
      SkeletonBox(height: AppSize.listRow),
      SizedBox(height: AppSpace.s2),
      SkeletonBox(height: AppSize.listRow),
    ],
  );
}
