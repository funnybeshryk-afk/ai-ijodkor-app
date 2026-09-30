import 'dart:math';
import 'dart:typed_data';

/// Homework attachments (Stage 1 D). Same rules as the platform's
/// src/lib/homework-files.ts and migration 0026: private bucket
/// `homework-files`, 10 MB, path `<student_id>/<uuid>-<name>`, fixed types.
const homeworkBucket = 'homework-files';
const maxHomeworkFileBytes = 10 * 1024 * 1024;

/// Extension -> content type sent to Storage (the bucket accepts only these).
const homeworkFileTypes = <String, String>{
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'pdf': 'application/pdf',
  'zip': 'application/zip',
  'py': 'text/x-python',
  'txt': 'text/plain',
  'sb3': 'application/x.scratch.sb3',
  'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
};

/// A file picked for a submission.
class HomeworkAttachment {
  const HomeworkAttachment({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

enum HomeworkFileProblem { type, empty, tooLarge }

String _extension(String name) {
  final dot = name.lastIndexOf('.');
  return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
}

/// Null when the file can be uploaded.
HomeworkFileProblem? checkHomeworkFile(String name, int size) {
  if (!homeworkFileTypes.containsKey(_extension(name))) {
    return HomeworkFileProblem.type;
  }
  if (size <= 0) return HomeworkFileProblem.empty;
  if (size > maxHomeworkFileBytes) return HomeworkFileProblem.tooLarge;
  return null;
}

String homeworkContentType(String name) =>
    homeworkFileTypes[_extension(name)] ?? 'application/octet-stream';

/// Storage keys must be plain ASCII; anything else becomes `_`.
String safeFileName(String name) {
  final ext = _extension(name);
  var base = ext.isEmpty
      ? name
      : name.substring(0, name.length - ext.length - 1);
  base = base
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
      .replaceAll(RegExp(r'^[._]+|_+$'), '');
  if (base.length > 60) base = base.substring(0, 60);
  if (base.isEmpty) base = 'fayl';
  return ext.isEmpty ? base : '$base.$ext';
}

/// A random v4 UUID (the prefix that keeps every upload unique).
String randomUuid([Random? random]) {
  final r = random ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}

String homeworkObjectPath(String studentId, String fileName, String id) =>
    '$studentId/$id-${safeFileName(fileName)}';

/// What `homework_submissions.file_url` points at.
class HomeworkFileRef {
  const HomeworkFileRef({required this.name, this.path});

  /// Display name (upload prefix stripped).
  final String name;

  /// Storage object path; null for old rows where the site kept only the
  /// file name and never stored the file (`pending-upload:<name>`).
  final String? path;

  bool get stored => path != null;

  static HomeworkFileRef? parse(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) return null;
    const legacy = 'pending-upload:';
    if (fileUrl.startsWith(legacy)) {
      return HomeworkFileRef(name: fileUrl.substring(legacy.length));
    }
    final last = fileUrl.substring(fileUrl.lastIndexOf('/') + 1);
    final name = last.replaceFirst(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-',
        caseSensitive: false,
      ),
      '',
    );
    return HomeworkFileRef(name: name, path: fileUrl);
  }
}
