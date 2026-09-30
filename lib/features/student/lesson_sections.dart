import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/markdown.dart';
import '../../data/models/lesson_section.dart';
import '../../widgets/ui.dart';
import '../common/web_page_screen.dart';
import 'student_providers.dart';

/// A lesson built from `lesson_sections`, natively (mockup «3 · Dars»), in
/// the content language.
class LessonSectionsView extends StatelessWidget {
  const LessonSectionsView({super.key, required this.sections});

  final List<LessonSection> sections;

  @override
  Widget build(BuildContext context) {
    final ru = context.contentRu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, section) in sections.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.s5),
          SectionView(
            key: ValueKey(section.id),
            content: section.contentFor(ru: ru),
            mediaPath: section.mediaPath,
          ),
        ],
      ],
    );
  }
}

class SectionView extends StatelessWidget {
  const SectionView({super.key, required this.content, this.mediaPath});

  final SectionContent content;
  final String? mediaPath;

  @override
  Widget build(BuildContext context) => switch (content) {
    TextContent(:final markdown) => MarkdownView(source: markdown),
    CodeContent(:final language, :final code) => CodeBlockView(
      language: language,
      code: code,
    ),
    final CalloutContent c => _Callout(content: c),
    final ExerciseContent e => _Exercise(content: e),
    final DiagramContent d => _Diagram(content: d),
    final ImageContent img => _Image(content: img, path: mediaPath),
    final VideoContent v => _Video(content: v, path: mediaPath),
    final TrainerLinkContent t => _TrainerLink(content: t),
  };
}

// ---------------------------------------------------------------------------
// Markdown
// ---------------------------------------------------------------------------

class MarkdownView extends StatelessWidget {
  const MarkdownView({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final blocks = parseMarkdown(source);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, block) in blocks.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpace.s3),
          _block(context, block),
        ],
      ],
    );
  }

  Widget _block(BuildContext context, MdBlock block) {
    final colors = context.colors;
    return switch (block) {
      MdHeading(:final level, :final children) => Padding(
        padding: const EdgeInsets.only(top: AppSpace.s2),
        child: Semantics(
          header: true,
          child: InlineText(
            children,
            style: (level == 2 ? AppText.displaySm : AppText.heading).copyWith(
              color: colors.ink,
            ),
          ),
        ),
      ),
      MdParagraph(:final children) => InlineText(
        children,
        style: AppText.bodyLg.copyWith(color: colors.ink),
      ),
      final MdList list => _ListView(list: list),
      final MdTable table => _TableView(table: table),
      MdCodeBlock(:final language, :final code) => CodeBlockView(
        language: language,
        code: code,
      ),
    };
  }
}

/// Inline markdown as rich text: bold, italic, `code`, tappable links.
class InlineText extends StatefulWidget {
  const InlineText(this.nodes, {super.key, required this.style});

  final List<MdInline> nodes;
  final TextStyle style;

  @override
  State<InlineText> createState() => _InlineTextState();
}

class _InlineTextState extends State<InlineText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  List<InlineSpan> _spans(List<MdInline> nodes, TextStyle style) {
    final colors = context.colors;
    return [
      for (final n in nodes)
        switch (n) {
          MdText(:final text) => TextSpan(text: text, style: style),
          MdStrong(:final children) => TextSpan(
            children: _spans(
              children,
              style.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          MdEm(:final children) => TextSpan(
            children: _spans(
              children,
              style.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          MdCode(:final text) => TextSpan(
            text: text,
            style: AppText.code.copyWith(
              fontSize: (style.fontSize ?? AppText.body.fontSize!) * 0.9,
              color: colors.ink,
              backgroundColor: colors.surfaceMuted,
            ),
          ),
          MdLink(:final href, :final children) => TextSpan(
            children: _spans(
              children,
              style.copyWith(
                color: colors.brandStrong,
                decoration: TextDecoration.underline,
              ),
            ),
            recognizer: _recognizer(href),
          ),
        },
    ];
  }

  TapGestureRecognizer _recognizer(String href) {
    final recognizer = TapGestureRecognizer()..onTap = () => _open(href);
    _recognizers.add(recognizer);
    return recognizer;
  }

  void _open(String href) {
    if (href.startsWith('/')) {
      if (Env.platformUrl.isEmpty) return;
      launchUrl(
        Uri.parse(Env.platformUrl).resolve(href),
        mode: LaunchMode.externalApplication,
      );
    } else {
      launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    return Text.rich(TextSpan(children: _spans(widget.nodes, widget.style)));
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.list, this.depth = 0});

  final MdList list;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = AppText.bodyLg.copyWith(color: colors.ink);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in list.items.indexed)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.s1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: AppSpace.s6,
                  child: list.ordered
                      ? Text(
                          '${list.start + i}.',
                          style: style.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.brandStrong,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSpace.s3),
                          child: Container(
                            width: AppSize.eventDot,
                            height: AppSize.eventDot,
                            decoration: BoxDecoration(
                              color: depth == 0 ? colors.brand : colors.inkSoft,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InlineText(item.children, style: style),
                      if (item.sublist != null)
                        _ListView(list: item.sublist!, depth: depth + 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TableView extends StatelessWidget {
  const _TableView({required this.table});

  final MdTable table;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cols = table.head.length;
    TableRow row(List<List<MdInline>> cells, {bool head = false}) => TableRow(
      decoration: head ? BoxDecoration(color: colors.surfaceMuted) : null,
      children: [
        for (var c = 0; c < cols; c++)
          Padding(
            padding: const EdgeInsets.all(AppSpace.s3),
            child: InlineText(
              c < cells.length ? cells[c] : const [],
              style: (head ? AppText.bodyStrong : AppText.body).copyWith(
                color: colors.ink,
              ),
            ),
          ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width - AppSpace.s5 * 2,
          ),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(
              color: colors.border,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            children: [
              row(table.head, head: true),
              for (final r in table.rows) row(r),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark code panel in JetBrains Mono; scrolls sideways, text selectable.
class CodeBlockView extends StatelessWidget {
  const CodeBlockView({super.key, required this.language, required this.code});

  final String language;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.inverse,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language != 'text')
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s4,
                AppSpace.s2,
                AppSpace.s4,
                0,
              ),
              child: Text(
                language.toUpperCase(),
                style: AppText.overline.copyWith(color: colors.inkSoft),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpace.s4),
            child: SelectableText(
              code,
              style: AppText.code.copyWith(color: colors.onInverse),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Other kinds
// ---------------------------------------------------------------------------

class _Callout extends StatelessWidget {
  const _Callout({required this.content});

  final CalloutContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (
      Color fill,
      Color? border,
      IconData icon,
      Color iconColor,
    ) = switch (content.tone) {
      CalloutTone.info => (
        colors.surfaceMuted,
        null,
        LucideIcons.info,
        colors.inkMuted,
      ),
      CalloutTone.warn => (
        colors.brandTint,
        colors.brand,
        LucideIcons.triangleAlert,
        colors.brandStrong,
      ),
      CalloutTone.good => (
        colors.surfaceMuted,
        colors.success,
        LucideIcons.circleCheck,
        colors.success,
      ),
    };
    return Panel(
      color: fill,
      bordered: border != null,
      borderColor: border,
      radius: AppRadius.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: AppSize.icon),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (content.title.isNotEmpty) ...[
                  Text(
                    content.title,
                    style: AppText.titleSm.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: AppSpace.s1),
                ],
                MarkdownView(source: content.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Exercise extends StatelessWidget {
  const _Exercise({required this.content});

  final ExerciseContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      radius: AppRadius.lg,
      borderColor: colors.brand,
      borderWidth: AppSize.borderInput,
      padding: const EdgeInsets.all(AppSpace.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(
                icon: content.practice
                    ? LucideIcons.hand
                    : LucideIcons.pencilLine,
              ),
              const SizedBox(width: AppSpace.s3),
              if (content.label.isNotEmpty)
                Expanded(
                  child: Text(
                    content.label.toUpperCase(),
                    style: AppText.overline.copyWith(color: colors.brandStrong),
                  ),
                ),
            ],
          ),
          if (content.title.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s3),
            Text(
              content.title,
              style: AppText.heading.copyWith(color: colors.ink),
            ),
          ],
          const SizedBox(height: AppSpace.s2),
          MarkdownView(source: content.text),
        ],
      ),
    );
  }
}

/// Replaces the legacy colour variables of an imported diagram with the
/// brand-book colours ([AppDiagram.colors]); flutter_svg knows no CSS
/// variables.
String resolveDiagramSvg(String svg) => svg.replaceAllMapped(
  RegExp(r'var\(\s*--([a-z-]+)\s*(?:,\s*([^)]+))?\)'),
  (m) =>
      AppDiagram.colors[m.group(1)] ??
      m.group(2)?.trim() ??
      AppDiagram.colors['ink']!,
);

class _Diagram extends StatelessWidget {
  const _Diagram({required this.content});

  final DiagramContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          color: AppDiagram.background,
          radius: AppRadius.md,
          padding: const EdgeInsets.all(AppSpace.s3),
          child: SvgPicture.string(
            resolveDiagramSvg(content.svg),
            semanticsLabel: content.alt.isNotEmpty
                ? content.alt
                : content.caption,
            errorBuilder: (context, _, _) => NotePanel(
              icon: LucideIcons.imageOff,
              text: l10n.sectionDiagramBroken,
            ),
          ),
        ),
        if (content.caption.isNotEmpty) ...[
          const SizedBox(height: AppSpace.s2),
          Text(
            content.caption,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );
  }
}

class _Image extends ConsumerWidget {
  const _Image({required this.content, this.path});

  final ImageContent content;
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final missing = NotePanel(
      icon: LucideIcons.imageOff,
      text: context.l10n.sectionImageMissing,
    );
    final url = path == null ? null : ref.watch(lessonMediaUrlProvider(path!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (url == null)
          missing
        else
          url.when(
            loading: () => const SkeletonBox(
              height: AppSize.mediaPanel,
              radius: AppRadius.md,
            ),
            error: (_, _) => missing,
            data: (uri) => ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.network(
                uri.toString(),
                semanticLabel: content.alt,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SkeletonBox(
                        height: AppSize.mediaPanel,
                        radius: AppRadius.md,
                      ),
                errorBuilder: (_, _, _) => missing,
              ),
            ),
          ),
        if (content.caption.isNotEmpty) ...[
          const SizedBox(height: AppSpace.s2),
          Text(
            content.caption,
            style: AppText.caption.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );
  }
}

class _Video extends ConsumerWidget {
  const _Video({required this.content, this.path});

  final VideoContent content;
  final String? path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final external = safeHref(content.url);
    Future<void> open() async {
      final Uri? target = path != null
          ? await ref.read(lessonMediaUrlProvider(path!).future)
          : external != null && !external.startsWith('/')
          ? Uri.parse(external)
          : null;
      if (target != null) {
        await launchUrl(target, mode: LaunchMode.externalApplication);
      }
    }

    final canOpen =
        path != null || (external != null && !external.startsWith('/'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.inverse,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canOpen ? open : null,
            child: SizedBox(
              height: AppSize.mediaPanel,
              child: Center(
                child: Semantics(
                  button: true,
                  label: context.l10n.sectionOpenVideo,
                  child: Container(
                    width: AppSize.playButton,
                    height: AppSize.playButton,
                    decoration: BoxDecoration(
                      color: colors.brand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.play,
                      size: AppSize.iconHero,
                      color: colors.onBrand,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (content.caption.isNotEmpty) ...[
          const SizedBox(height: AppSpace.s2),
          Text(
            content.caption,
            style: AppText.caption.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );
  }
}

class _TrainerLink extends StatelessWidget {
  const _TrainerLink({required this.content});

  final TrainerLinkContent content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final href = content.href;
    final internal = href.startsWith('/') && !href.startsWith('//');
    // Trainers have their own screens; other platform pages (the agent
    // builder) open in the signed-in WebView.
    final VoidCallback? onStart = !internal
        ? null
        : href.startsWith('/student/practice/')
        ? () => context.push(href)
        : Env.platformUrl.isEmpty
        ? null
        : () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (_) => WebPageScreen(
                url: Uri.parse(Env.platformUrl).resolve(href),
                title: content.title,
                withPlatformSession: true,
              ),
            ),
          );
    return Panel(
      color: colors.inverse,
      bordered: false,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpace.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (content.title.isNotEmpty)
            Text(
              content.title,
              style: AppText.heading.copyWith(color: colors.onInverse),
            ),
          if (content.text.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s1),
            Text(
              content.text,
              style: AppText.body.copyWith(color: colors.inkSoft),
            ),
          ],
          const SizedBox(height: AppSpace.s4),
          if (onStart != null)
            PrimaryButton(
              key: const Key('section_trainer_start'),
              label: l10n.sectionStartButton,
              trailingIcon: LucideIcons.arrowRight,
              height: AppSize.button,
              onPressed: onStart,
            )
          else
            Text(
              l10n.sectionLinkUnavailable,
              style: AppText.caption.copyWith(color: colors.inkSoft),
            ),
        ],
      ),
    );
  }
}
