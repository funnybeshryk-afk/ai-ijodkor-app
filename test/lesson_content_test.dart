import 'package:ai_ijodkor/core/theme.dart';
import 'package:ai_ijodkor/data/markdown.dart';
import 'package:ai_ijodkor/data/models/lesson_section.dart';
import 'package:ai_ijodkor/features/student/lesson_sections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMarkdown', () {
    test('reads headings, paragraphs, nested lists, tables and code', () {
      final blocks = parseMarkdown(
        [
          '## 1. Sikl',
          '',
          'Birinchi qator',
          'davomi.',
          '',
          '- **for** sikli',
          '   - ichki band',
          '- `while`',
          '',
          '3. uch',
          '4. to‘rt',
          '',
          '| A | B |',
          '| --- | --- |',
          '| 1 | 2 |',
          '',
          '```python',
          'print(1)',
          '```',
        ].join('\n'),
      );
      expect(blocks.map((b) => b.runtimeType).toList(), [
        MdHeading,
        MdParagraph,
        MdList,
        MdList,
        MdTable,
        MdCodeBlock,
      ]);
      expect(
        inlineText((blocks[1] as MdParagraph).children),
        'Birinchi qator davomi.',
      );
      final ul = blocks[2] as MdList;
      expect(ul.ordered, isFalse);
      expect(ul.items, hasLength(2));
      expect(ul.items.first.sublist!.items, hasLength(1));
      final ol = blocks[3] as MdList;
      expect(ol.ordered, isTrue);
      expect(ol.start, 3);
      expect((blocks[4] as MdTable).rows, hasLength(1));
      final code = blocks[5] as MdCodeBlock;
      expect(code.language, 'python');
      expect(code.code, 'print(1)');
    });

    test('inline marks; markup inside code spans stays literal', () {
      final nodes = parseInline('**qalin** va *kursiv* hamda `a*b*c`, 2 * 3');
      expect(nodes[0], isA<MdStrong>());
      expect(nodes[2], isA<MdEm>());
      expect((nodes[4] as MdCode).text, 'a*b*c');
      expect(inlineText(nodes), 'qalin va kursiv hamda a*b*c, 2 * 3');
    });

    test('only safe links become links', () {
      expect(parseInline('[bu](https://example.com)').single, isA<MdLink>());
      expect(
        (parseInline('[bu](/student/practice/typing)').single as MdLink).href,
        '/student/practice/typing',
      );
      expect(parseInline('[bu](javascript:alert(1))').first, isA<MdText>());
      expect(safeHref('//evil.example'), isNull);
    });
  });

  group('sections', () {
    test('bodies parse per kind and never throw', () {
      final code = SectionContent.parse(
        SectionKind.code,
        '{"language":"python","code":"print(1)"}',
      );
      expect(code, isA<CodeContent>());
      final broken = SectionContent.parse(SectionKind.callout, 'not json');
      expect((broken as TextContent).markdown, 'not json');
      final ex = SectionContent.parse(
        SectionKind.exercise,
        '{"variant":"practice","label":"Sinab ko\'ring!","title":"T","text":"x"}',
      );
      expect((ex as ExerciseContent).practice, isTrue);
    });

    test(
      'Russian falls back to Uzbek when empty; unknown kinds are skipped',
      () {
        const s = LessonSection(
          id: 's',
          orderIndex: 0,
          kind: SectionKind.text,
          bodyUz: 'uz',
          bodyRu: '  ',
        );
        expect(s.bodyFor(ru: true), 'uz');
        expect(
          LessonSection.fromJson({
            'id': 'x',
            'order_index': 0,
            'kind': 'hologram',
            'body_uz': 'x',
          }),
          isNull,
        );
      },
    );

    test('diagram colour variables become brand colours', () {
      final svg = resolveDiagramSvg(
        '<svg><rect fill="var(--moss)" stroke="var(--nope, #123456)"/></svg>',
      );
      expect(svg, contains('fill="${AppDiagram.colors['moss']}"'));
      expect(svg, contains('stroke="#123456"'));
      expect(svg, isNot(contains('var(')));
    });
  });
}
