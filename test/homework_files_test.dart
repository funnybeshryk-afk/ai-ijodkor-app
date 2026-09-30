import 'dart:math';

import 'package:ai_ijodkor/data/homework_files.dart';
import 'package:flutter_test/flutter_test.dart';

const s = '00000000-0000-0000-0000-000000000201';
const id = '3f2b8c1e-1d2a-4b3c-9d4e-5f6a7b8c9d0e';

void main() {
  test('accepts known types, refuses others, empty and oversized', () {
    expect(checkHomeworkFile('loyiha.sb3', 100), isNull);
    expect(homeworkContentType('main.PY'), 'text/x-python');
    expect(checkHomeworkFile('virus.exe', 100), HomeworkFileProblem.type);
    expect(checkHomeworkFile('a.png', 0), HomeworkFileProblem.empty);
    expect(
      checkHomeworkFile('a.png', maxHomeworkFileBytes + 1),
      HomeworkFileProblem.tooLarge,
    );
  });

  test('builds ASCII paths inside the student folder', () {
    expect(safeFileName('Mening loyiham (2).docx'), 'Mening_loyiham_2.docx');
    expect(safeFileName('Скрин.png'), 'fayl.png');
    expect(homeworkObjectPath(s, 'javob.py', id), '$s/$id-javob.py');
  });

  test('random ids are v4 UUIDs the name parser strips', () {
    final uuid = randomUuid(Random(1));
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(uuid),
      isTrue,
    );
    expect(HomeworkFileRef.parse('$s/$uuid-javob.py')!.name, 'javob.py');
  });

  test('parses stored and legacy references', () {
    expect(HomeworkFileRef.parse(null), isNull);
    final legacy = HomeworkFileRef.parse('pending-upload:Kitob.docx')!;
    expect(legacy.name, 'Kitob.docx');
    expect(legacy.stored, isFalse);
    final stored = HomeworkFileRef.parse('$s/$id-javob.py')!;
    expect(stored.path, '$s/$id-javob.py');
    expect(stored.stored, isTrue);
  });
}
