import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Creates a temporary Dart file with the given content for lint testing.
File writeToTemporaryFile(String content) {
  final tempDir = Directory.systemTemp.createTempSync();
  addTearDown(() => tempDir.deleteSync(recursive: true));

  final file = File(p.join(tempDir.path, 'file.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  return file;
}
