import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/homework_files.dart';

/// Outcome of picking a homework file: the file, or why it can't be sent.
typedef PickedHomeworkFile = ({
  HomeworkAttachment? file,
  HomeworkFileProblem? problem,
});

/// Opens the system picker. A provider so widget tests can swap it out.
final homeworkFilePickerProvider =
    Provider<Future<PickedHomeworkFile?> Function()>((ref) => pickHomeworkFile);

Future<PickedHomeworkFile?> pickHomeworkFile() async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: homeworkFileTypes.keys.toList(),
  );
  if (picked == null) return null;
  // Check the size before reading: a huge file must not land in memory.
  final length = await picked.length();
  if (length != null) {
    final problem = checkHomeworkFile(picked.name, length);
    if (problem != null) return (file: null, problem: problem);
  }
  final bytes = await picked.readAsBytes();
  final problem = checkHomeworkFile(picked.name, bytes.length);
  if (problem != null) return (file: null, problem: problem);
  return (
    file: HomeworkAttachment(name: picked.name, bytes: bytes),
    problem: null,
  );
}
