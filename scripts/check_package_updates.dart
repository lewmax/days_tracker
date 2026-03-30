// ignore_for_file: avoid_print
// @dart=3.2

import 'dart:convert';
import 'dart:io';

import 'helpers/flutter_utils.dart';
import 'helpers/package_updates_helper.dart';

/// Checks Dart/Flutter packages for updates and prints changelog excerpts.
///
/// Run from project root:
///   dart run scripts/check_package_updates.dart
///   fvm dart run scripts/check_package_updates.dart
///
/// Options:
///   --direct-only   Only show direct and dev dependencies (exclude transitive)
///   --no-links      Omit changelog URLs from output
///   --no-fetch      Skip fetching changelog excerpts (links only, no network)
void main(List<String> args) async {
  final directOnly = args.contains('--direct-only');
  final includeLinks = !args.contains('--no-links');
  final fetchChangelogs = !args.contains('--no-fetch');

  final projectRoot = Directory.current.path;
  final pubspecPath = '$projectRoot/pubspec.yaml';
  final hasFlutter = File(pubspecPath).existsSync() &&
      File(pubspecPath).readAsStringSync().contains('sdk: flutter');

  print('Checking for package updates...\n');

  final data = await runPubOutdated(projectRoot, hasFlutter);
  if (data == null) {
    print('Failed to run pub outdated.');
    exit(1);
  }

  final outdated = parseOutdatedPackages(data, directOnly);
  if (outdated.isEmpty) {
    print('✓ All packages are up to date!');
    exit(0);
  }

  await printPackageReport(outdated, includeLinks, fetchChangelogs);
  exit(0);
}

Future<Map<String, dynamic>?> runPubOutdated(String projectRoot, bool hasFlutter) async {
  final executable = hasFlutter ? flutterExecutable(projectRoot) : Platform.resolvedExecutable;
  final result = await Process.run(
    executable,
    ['pub', 'outdated', '--json', '--up-to-date'],
    workingDirectory: projectRoot,
    runInShell: true,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) return null;
  try {
    return jsonDecode(result.stdout.toString().trim()) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
