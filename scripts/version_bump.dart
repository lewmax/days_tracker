// ignore_for_file: avoid_print
// @dart=3.2

import 'dart:io';

/// Bump version in pubspec.yaml and versionCode in build.gradle.kts.
/// Run: fvm dart run scripts/version_bump.dart [major|minor|patch]
///   major: 2.1.2 -> 3.0.0
///   minor: 2.1.2 -> 2.2.0
///   patch: 2.1.2 -> 2.1.3
void main(List<String> args) {
  if (args.isEmpty || !['major', 'minor', 'patch'].contains(args[0])) {
    print('Usage: fvm dart run scripts/version_bump.dart [major|minor|patch]');
    exit(1);
  }
  final bump = args[0];

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('pubspec.yaml not found');
    exit(1);
  }

  var content = pubspec.readAsStringSync();
  final versionMatch = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)(?:\+\d+)?').firstMatch(content);
  if (versionMatch == null) {
    print('Could not find version in pubspec.yaml');
    exit(1);
  }

  var major = int.parse(versionMatch[1]!);
  var minor = int.parse(versionMatch[2]!);
  var patch = int.parse(versionMatch[3]!);

  switch (bump) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
    case 'minor':
      minor++;
      patch = 0;
    case 'patch':
      patch++;
  }

  final newVersion = '$major.$minor.$patch';
  content = content.replaceFirst(RegExp(r'version:\s*[\d.]+(?:\+\d+)?'), 'version: $newVersion');
  pubspec.writeAsStringSync(content);
  print('Updated pubspec.yaml: version: $newVersion');

  final gradle = File('android/app/build.gradle.kts');
  if (gradle.existsSync()) {
    var gradleContent = gradle.readAsStringSync();
    final codeMatch = RegExp(r'versionCode\s*=\s*(\d+)').firstMatch(gradleContent);
    if (codeMatch != null) {
      final newCode = int.parse(codeMatch[1]!) + 1;
      gradleContent =
          gradleContent.replaceFirst(RegExp(r'versionCode\s*=\s*\d+'), 'versionCode = $newCode');
      gradle.writeAsStringSync(gradleContent);
      print('Updated android/app/build.gradle.kts: versionCode = $newCode');
    }
  }
}
