import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/review.dart';
import '../../widgets/ui.dart';

/// What the student has chosen so far for one question (the five task types).
class TaskAnswer {
  TaskAnswer({
    this.single,
    List<int>? multi,
    this.text = '',
    required this.order,
    required this.match,
  }) : multi = multi ?? [];

  /// A fresh, empty answer for [question].
  factory TaskAnswer.initial(ReviewQuestion question) => TaskAnswer(
    order: [
      for (var i = 0; i < question.texts('items', ru: false).length; i++) i,
    ],
    match: [
      for (var i = 0; i < question.texts('left', ru: false).length; i++) null,
    ],
  );

  int? single;
  List<int> multi;
  String text;

  /// order: the item shown at each position (indexes into `items`).
  List<int> order;

  /// match: for each left item the chosen right item.
  List<int?> match;

  /// The answer in the shape submit_review expects, or null while incomplete.
  Map<String, dynamic>? toJson(String type) => switch (type) {
    'single_choice' => single == null ? null : {'index': single},
    'multi_choice' => multi.isEmpty ? null : {'indexes': List.of(multi)},
    'short_text' => text.trim().isEmpty ? null : {'text': text},
    'order' => {'order': List.of(order)},
    'match' =>
      match.every((r) => r != null)
          ? {
              'pairs': [
                for (final (l, r) in match.indexed) [l, r],
              ],
            }
          : null,
    _ => null,
  };
}

/// The answer widgets of the five task types — single/multi choice, short text,
/// order, match — in the brand's own components. Controlled: the owner keeps the
/// [TaskAnswer] and rebuilds on [onChanged].
class TaskAnswerInput extends StatefulWidget {
  const TaskAnswerInput({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
    this.enabled = true,
  });

  final ReviewQuestion question;
  final TaskAnswer answer;
  final VoidCallback onChanged;
  final bool enabled;

  @override
  State<TaskAnswerInput> createState() => _TaskAnswerInputState();
}

class _TaskAnswerInputState extends State<TaskAnswerInput> {
  late final TextEditingController _text = TextEditingController(
    text: widget.answer.text,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _change(VoidCallback mutate) {
    if (!widget.enabled) return;
    mutate();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final ru = context.contentRu;
    final q = widget.question;
    final a = widget.answer;

    switch (q.type) {
      case 'single_choice':
        return Column(
          children: [
            for (final (i, label) in q.texts('options', ru: ru).indexed)
              _OptionTile(
                key: Key('option_$i'),
                label: label,
                selected: a.single == i,
                multi: false,
                onTap: widget.enabled
                    ? () => _change(() => a.single = i)
                    : null,
              ),
          ],
        );
      case 'multi_choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taskMultiHint,
              style: AppText.caption.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: AppSpace.s2),
            for (final (i, label) in q.texts('options', ru: ru).indexed)
              _OptionTile(
                key: Key('option_$i'),
                label: label,
                selected: a.multi.contains(i),
                multi: true,
                onTap: widget.enabled
                    ? () => _change(() {
                        a.multi.contains(i)
                            ? a.multi.remove(i)
                            : a.multi.add(i);
                      })
                    : null,
              ),
          ],
        );
      case 'short_text':
        return TextField(
          key: const Key('answer_text'),
          controller: _text,
          enabled: widget.enabled,
          maxLength: 500,
          style: AppText.input.copyWith(color: colors.ink),
          decoration: InputDecoration(
            hintText: l10n.taskTextHint,
            counterText: '',
            constraints: const BoxConstraints(minHeight: AppSize.input),
          ),
          onChanged: (v) => _change(() => a.text = v),
        );
      case 'order':
        final items = q.texts('items', ru: ru);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taskOrderHint,
              style: AppText.caption.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: AppSpace.s2),
            for (final (pos, itemIndex) in a.order.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.s2),
                child: Panel(
                  padding: const EdgeInsets.only(left: AppSpace.card),
                  child: Row(
                    children: [
                      Text(
                        '${pos + 1}',
                        style: AppText.label.copyWith(color: colors.inkSoft),
                      ),
                      const SizedBox(width: AppSpace.s3),
                      Expanded(
                        child: Text(
                          itemIndex < items.length ? items[itemIndex] : '',
                          style: AppText.bodyLg.copyWith(color: colors.ink),
                        ),
                      ),
                      IconButton(
                        key: Key('up_$pos'),
                        tooltip: l10n.taskMoveUp,
                        constraints: const BoxConstraints(
                          minWidth: AppSize.touch,
                          minHeight: AppSize.touch,
                        ),
                        icon: const Icon(
                          LucideIcons.arrowUp,
                          size: AppSize.iconMd,
                        ),
                        onPressed: widget.enabled && pos > 0
                            ? () => _change(() => _move(a.order, pos, -1))
                            : null,
                      ),
                      IconButton(
                        key: Key('down_$pos'),
                        tooltip: l10n.taskMoveDown,
                        constraints: const BoxConstraints(
                          minWidth: AppSize.touch,
                          minHeight: AppSize.touch,
                        ),
                        icon: const Icon(
                          LucideIcons.arrowDown,
                          size: AppSize.iconMd,
                        ),
                        onPressed: widget.enabled && pos < a.order.length - 1
                            ? () => _change(() => _move(a.order, pos, 1))
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      case 'match':
        final left = q.texts('left', ru: ru);
        final right = q.texts('right', ru: ru);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taskMatchHint,
              style: AppText.caption.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: AppSpace.s2),
            for (final (li, label) in left.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.bodyStrong.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: AppSpace.s1),
                    DropdownButtonFormField<int>(
                      key: Key('match_$li'),
                      initialValue: a.match[li],
                      isExpanded: true,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(minHeight: AppSize.input),
                      ),
                      items: [
                        for (final (ri, r) in right.indexed)
                          DropdownMenuItem(
                            value: ri,
                            child: Text(r, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: widget.enabled
                          ? (v) => _change(() => a.match[li] = v)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static void _move(List<int> order, int index, int delta) {
    final it = order.removeAt(index);
    order.insert(index + delta, it);
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool multi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = multi
        ? (selected ? LucideIcons.squareCheck : LucideIcons.square)
        : (selected ? LucideIcons.circleDot : LucideIcons.circle);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s2),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: !multi,
        child: Panel(
          color: selected ? colors.brandTint : colors.surfaceCard,
          borderColor: selected ? colors.brand : colors.border,
          borderWidth: AppSize.borderInput,
          padding: const EdgeInsets.all(AppSpace.card),
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? colors.brandStrong : colors.inkMuted,
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Text(
                  label,
                  style: AppText.bodyLg.copyWith(color: colors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
