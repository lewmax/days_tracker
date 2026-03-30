// ignore_for_file: avoid_print
// @dart=3.2

import 'dart:io';

import 'helpers/flutter_utils.dart';

/// Pre-commit checks: format, analyze, custom_lint, tests.
/// Run from project root: fvm dart run scripts/pre_commit.dart
/// Options: --no-tests to skip tests, --no-format to skip format
void main(List<String> args) async {
  final projectRoot = Directory.current.path;
  final flutter = flutterExecutable(projectRoot);
  final fvmDart = '$projectRoot/.fvm/flutter_sdk/bin/dart';
  final dart = File(fvmDart).existsSync() ? fvmDart : 'dart';

  final runTests = !args.contains('--no-tests');
  final runFormat = !args.contains('--no-format');

  var failed = false;

  if (runFormat) {
    print('\nRunning dart format (lib, excl. generated)...');
    final formatCmd = 'find lib -name "*.dart" -not -path "lib/generated/*" '
        '-not -name "*.freezed.dart" -not -name "*.g.dart" '
        '-not -name "*.config.dart" -not -name "*.gen.dart" -not -name "*.gr.dart" '
        '-print0 | xargs -0 "$dart" format --line-length=100';
    final formatCmdResolved = formatCmd.replaceFirst(r'$dart', dart);
    if (await _runShell('sh', ['-c', formatCmdResolved]) != 0) failed = true;
  }
  print('\nRunning dart analyze...');
  if (await _run([dart, 'analyze']) != 0) failed = true;
  print('\nRunning custom_lint...');
  if (await _run([dart, 'run', 'custom_lint']) != 0) failed = true;
  if (runTests) {
    print('\nRunning tests...');
    if (await _run([flutter, 'test', 'test/']) != 0) failed = true;
  }

  if (failed) {
    print('\n\x1b[31mPre-commit checks failed.\x1b[0m');
    exit(1);
  }
  print('\n\x1b[32mAll pre-commit checks passed.\x1b[0m');
}

Future<int> _run(List<String> cmd) async {
  final p = await Process.start(cmd.first, cmd.skip(1).toList(),
      workingDirectory: Directory.current.path,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio);
  return p.exitCode;
}

Future<int> _runShell(String executable, List<String> args) async {
  final p = await Process.start(executable, args,
      workingDirectory: Directory.current.path, mode: ProcessStartMode.inheritStdio);
  return p.exitCode;
}
