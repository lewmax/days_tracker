// @dart=3.2

import 'dart:io';

/// Returns path to Flutter: .fvm/flutter_sdk/bin/flutter if present, else 'flutter'.
String flutterExecutable(String projectRoot) {
  final fvmFlutter = '$projectRoot/.fvm/flutter_sdk/bin/flutter';
  if (File(fvmFlutter).existsSync()) return fvmFlutter;
  return 'flutter';
}
