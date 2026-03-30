// @dart=3.2

import 'dart:io';

Future<String> gitBranch(String projectRoot) async {
  final r = await Process.run(
    'git',
    ['branch', '--show-current'],
    workingDirectory: projectRoot,
    runInShell: true,
  );
  return r.stdout.toString().trim();
}

Future<String> gitLog(String projectRoot, int n) async {
  final r = await Process.run(
    'git',
    ['log', '-$n', '--format=%s'],
    workingDirectory: projectRoot,
    runInShell: true,
  );
  return r.stdout.toString().trim().split('\n').firstOrNull ?? '';
}

Future<String> gitRevParse(String projectRoot, String arg, String ref) async {
  final r = await Process.run(
    'git',
    ['rev-parse', arg, ref],
    workingDirectory: projectRoot,
    runInShell: true,
  );
  return r.stdout.toString().trim();
}

String getVersion(String projectRoot) {
  final content = File('$projectRoot/pubspec.yaml').readAsStringSync();
  final match = RegExp(r'version:\s*([0-9.]+)').firstMatch(content);
  return match?.group(1) ?? '0.0.0';
}
