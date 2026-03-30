// ignore_for_file: avoid_print
// @dart=3.2

import 'dart:io';

import 'helpers/coverage_helper.dart';
import 'helpers/flutter_utils.dart';

/// Runs tests with coverage and reports coverage for lib/ excluding generated files.
/// Only files with at least one line hit are included in the total (0% files excluded).
/// Fails with exit 1 if coverage is below 75%.
///
/// Run from project root:
///   dart run scripts/check_coverage.dart
///   fvm dart run scripts/check_coverage.dart
void main(List<String> args) async {
  final projectRoot = Directory.current.path;

  final exitCode = await runCoverage(projectRoot);
  if (exitCode != 0) exit(exitCode);

  final passed = checkCoverage(projectRoot, onPrint: print);
  if (!passed) exit(1);
}

/// Runs coverage check. Returns exit code (0 = pass).
Future<int> runCoverage(String projectRoot) async {
  final flutterCmd = flutterExecutable(projectRoot);
  final process = await Process.start(
    flutterCmd,
    ['test', 'test/', '--coverage'],
    workingDirectory: projectRoot,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}
