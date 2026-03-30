// ignore_for_file: avoid_print
// @dart=3.2

import 'dart:convert';
import 'dart:io';

import 'helpers/lint_report_helper.dart';

/// Runs custom_lint with JSON output and formats a readable report with stats.
void main() async {
  final projectRoot = Directory.current.path;

  final (exitCode, stdoutStr) = await runCustomLint(projectRoot);

  final (data, _) = parseLintOutput(stdoutStr);
  if (data == null) {
    print(stdoutStr);
    exit(exitCode);
  }

  final issues = parseDiagnostics(data, projectRoot);
  if (issues.isEmpty) {
    print('');
    print('✓ No issues found!');
    exit(0);
  }

  printLintReport(issues, projectRoot);
  exit(exitCode);
}

/// Runs custom_lint and returns (exitCode, stdout).
Future<(int, String)> runCustomLint(String projectRoot) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['run', 'custom_lint', '--format', 'json'],
    workingDirectory: projectRoot,
    runInShell: true,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.stderr.toString().trim().isNotEmpty) print(result.stderr);
  return (result.exitCode, result.stdout.toString().trim());
}
