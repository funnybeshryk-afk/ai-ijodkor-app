import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/parent_records.dart';
import '../../data/models/teacher_records.dart';
import '../../widgets/ui.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// Bottom sheet to mark one student's month paid/unpaid with its amount.
Future<void> showPaymentSheet(
  BuildContext context, {
  required Person student,
  required String period,
  required num amount,
  required PaymentStatus status,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _PaymentSheet(
    student: student,
    period: period,
    amount: amount,
    status: status,
  ),
);

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({
    required this.student,
    required this.period,
    required this.amount,
    required this.status,
  });

  final Person student;
  final String period;
  final num amount;
  final PaymentStatus status;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  late final _amount = TextEditingController(
    text: widget.amount.round().toString(),
  );
  late PaymentStatus _status = widget.status;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount < 0) {
      setState(() => _error = l10n.amountInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await runAction(
      context,
      () => ref
          .read(teacherActionsProvider)
          .markPayment(
            widget.student.id,
            widget.period,
            amount: amount,
            status: _status,
          ),
      successMessage: l10n.savedMessage,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final year = int.parse(widget.period.substring(0, 4));
    final month = int.parse(widget.period.substring(5, 7));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.s5,
        0,
        AppSpace.s5,
        AppSpace.s5 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.markPaymentTitle(
              widget.student.fullName,
              formatPeriod(context, year, month),
            ),
            style: AppText.heading.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpace.s4),
          SegmentedButton<PaymentStatus>(
            key: const Key('payment_status'),
            segments: [
              ButtonSegment(
                value: PaymentStatus.paid,
                label: Text(l10n.paymentPaid),
              ),
              ButtonSegment(
                value: PaymentStatus.unpaid,
                label: Text(l10n.paymentUnpaid),
              ),
            ],
            selected: {_status},
            onSelectionChanged: _busy
                ? null
                : (s) => setState(() => _status = s.first),
          ),
          const SizedBox(height: AppSpace.s4),
          TextField(
            key: const Key('payment_amount'),
            controller: _amount,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.amountLabel,
              errorText: _error,
            ),
          ),
          const SizedBox(height: AppSpace.s5),
          PrimaryButton(
            key: const Key('payment_save'),
            label: l10n.saveButton,
            busy: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
