/// The markdown subset of lesson sections, same as the platform's
/// src/lib/markdown.ts: ## headings, paragraphs, - / 1. lists (nested by
/// indentation), | tables |, ``` fenced code, **bold**, *italic*, `code`
/// and [links](https://…). Parsed into a tree that widgets render — raw
/// markup never reaches the screen.
library;

sealed class MdInline {
  const MdInline();
}

class MdText extends MdInline {
  const MdText(this.text);
  final String text;
}

class MdStrong extends MdInline {
  const MdStrong(this.children);
  final List<MdInline> children;
}

class MdEm extends MdInline {
  const MdEm(this.children);
  final List<MdInline> children;
}

class MdCode extends MdInline {
  const MdCode(this.text);
  final String text;
}

class MdLink extends MdInline {
  const MdLink(this.href, this.children);
  final String href;
  final List<MdInline> children;
}

sealed class MdBlock {
  const MdBlock();
}

class MdHeading extends MdBlock {
  const MdHeading(this.level, this.children);
  final int level;
  final List<MdInline> children;
}

class MdParagraph extends MdBlock {
  const MdParagraph(this.children);
  final List<MdInline> children;
}

class MdListItem {
  const MdListItem(this.children, [this.sublist]);
  final List<MdInline> children;
  final MdList? sublist;
}

class MdList extends MdBlock {
  const MdList({
    required this.ordered,
    required this.start,
    required this.items,
  });
  final bool ordered;
  final int start;
  final List<MdListItem> items;
}

class MdTable extends MdBlock {
  const MdTable(this.head, this.rows);
  final List<List<MdInline>> head;
  final List<List<List<MdInline>>> rows;
}

class MdCodeBlock extends MdBlock {
  const MdCodeBlock(this.language, this.code);
  final String language;
  final String code;
}

final _listItem = RegExp(r'^(\s*)([-*]|\d+[.)])\s+(.*)$');
final _tableSeparator = RegExp(
  r'^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$',
);
final _fenceOpen = RegExp(r'^```\s*([\w+-]*)\s*$');
final _fenceClose = RegExp(r'^```\s*$');
final _heading = RegExp(r'^(#{1,4})\s+(.*)$');

List<MdBlock> parseMarkdown(String source) {
  final lines = source
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');
  final blocks = <MdBlock>[];
  var i = 0;
  bool tableStart(int at) =>
      lines[at].trim().startsWith('|') &&
      at + 1 < lines.length &&
      _tableSeparator.hasMatch(lines[at + 1]);

  while (i < lines.length) {
    final line = lines[i];
    if (line.trim().isEmpty) {
      i++;
      continue;
    }
    final fence = _fenceOpen.firstMatch(line);
    if (fence != null) {
      final code = <String>[];
      i++;
      while (i < lines.length && !_fenceClose.hasMatch(lines[i])) {
        code.add(lines[i++]);
      }
      i++;
      final lang = fence.group(1) ?? '';
      blocks.add(MdCodeBlock(lang.isEmpty ? 'text' : lang, code.join('\n')));
      continue;
    }
    final heading = _heading.firstMatch(line);
    if (heading != null) {
      final level = heading.group(1)!.length.clamp(2, 4);
      blocks.add(MdHeading(level, parseInline(heading.group(2)!.trim())));
      i++;
      continue;
    }
    if (tableStart(i)) {
      final head = _splitRow(line);
      i += 2;
      final rows = <List<List<MdInline>>>[];
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        rows.add(_splitRow(lines[i++]));
      }
      blocks.add(MdTable(head, rows));
      continue;
    }
    if (_listItem.hasMatch(line)) {
      final listLines = <String>[];
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          (_listItem.hasMatch(lines[i]) ||
              RegExp(r'^\s+\S').hasMatch(lines[i]))) {
        listLines.add(lines[i++]);
      }
      blocks.add(_parseList(listLines));
      continue;
    }
    final para = <String>[];
    while (i < lines.length &&
        lines[i].trim().isNotEmpty &&
        !_listItem.hasMatch(lines[i]) &&
        !RegExp(r'^#{1,4}\s').hasMatch(lines[i]) &&
        !lines[i].startsWith('```') &&
        !tableStart(i)) {
      para.add(lines[i++].trim());
    }
    blocks.add(MdParagraph(parseInline(para.join(' '))));
  }
  return blocks;
}

List<List<MdInline>> _splitRow(String line) {
  var row = line.trim();
  if (row.startsWith('|')) row = row.substring(1);
  if (row.endsWith('|')) row = row.substring(0, row.length - 1);
  return [for (final cell in row.split('|')) parseInline(cell.trim())];
}

MdList _parseList(List<String> lines) {
  int indentOf(String l) => RegExp(r'^(\s*)').firstMatch(l)!.group(1)!.length;
  final base = lines
      .where(_listItem.hasMatch)
      .map(indentOf)
      .reduce((a, b) => a < b ? a : b);
  final first = _listItem.firstMatch(lines.first)!;
  final ordered = RegExp(r'\d').hasMatch(first.group(2)!);
  final start = ordered
      ? int.parse(RegExp(r'\d+').firstMatch(first.group(2)!)!.group(0)!)
      : 1;
  final items = <MdListItem>[];
  String? text;
  var nested = <String>[];
  void flush() {
    if (text == null) return;
    items.add(
      MdListItem(parseInline(text), nested.isEmpty ? null : _parseList(nested)),
    );
  }

  for (final line in lines) {
    final m = _listItem.firstMatch(line);
    if (m != null && indentOf(line) <= base) {
      flush();
      text = m.group(3)!;
      nested = <String>[];
    } else if (text != null) {
      if (m != null) {
        nested.add(line);
      } else {
        text = '$text ${line.trim()}';
      }
    }
  }
  flush();
  return MdList(ordered: ordered, start: start, items: items);
}

/// Only absolute http(s) links and site-relative paths become links.
String? safeHref(String href) {
  final h = href.trim();
  if (h.startsWith('/') && !h.startsWith('//')) return h;
  final uri = Uri.tryParse(h);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
    return null;
  }
  return uri.host.isEmpty ? null : uri.toString();
}

List<MdInline> parseInline(String text) {
  final out = <MdInline>[];
  final buf = StringBuffer();
  void pushText() {
    if (buf.isNotEmpty) out.add(MdText(buf.toString()));
    buf.clear();
  }

  var i = 0;
  while (i < text.length) {
    final ch = text[i];
    final next = i + 1 < text.length ? text[i + 1] : '';
    if (ch == '`') {
      final end = text.indexOf('`', i + 1);
      if (end > i) {
        pushText();
        out.add(MdCode(text.substring(i + 1, end)));
        i = end + 1;
        continue;
      }
    }
    if (ch == '*' && next == '*') {
      final end = text.indexOf('**', i + 2);
      if (end > i + 2) {
        pushText();
        out.add(MdStrong(parseInline(text.substring(i + 2, end))));
        i = end + 2;
        continue;
      }
    }
    if (ch == '*' && next.isNotEmpty && next != ' ' && next != '*') {
      final end = _closingStar(text, i + 1);
      if (end > 0) {
        pushText();
        out.add(MdEm(parseInline(text.substring(i + 1, end))));
        i = end + 1;
        continue;
      }
    }
    if (ch == '[') {
      final close = text.indexOf('](', i + 1);
      final end = close > 0 ? text.indexOf(')', close + 2) : -1;
      if (close > 0 && end > 0) {
        final href = safeHref(text.substring(close + 2, end));
        final label = parseInline(text.substring(i + 1, close));
        pushText();
        if (href != null) {
          out.add(MdLink(href, label));
        } else {
          out.addAll(label);
        }
        i = end + 1;
        continue;
      }
    }
    buf.write(ch);
    i++;
  }
  pushText();
  return out;
}

int _closingStar(String text, int from) {
  for (var j = from; j < text.length; j++) {
    final c = text[j];
    if (c == '`') {
      final end = text.indexOf('`', j + 1);
      if (end > j) {
        j = end;
        continue;
      }
    }
    final next = j + 1 < text.length ? text[j + 1] : '';
    final prev = text[j - 1];
    if (c == '*' && next != '*' && prev != ' ' && prev != '*') return j;
    if (c == '*' && next == '*') j++;
  }
  return -1;
}

/// Plain text of inline nodes (semantics labels, tests).
String inlineText(List<MdInline> nodes) => nodes
    .map(
      (n) => switch (n) {
        MdText(:final text) || MdCode(:final text) => text,
        MdStrong(:final children) ||
        MdEm(:final children) ||
        MdLink(:final children) => inlineText(children),
      },
    )
    .join();
