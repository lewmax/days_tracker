// @dart=3.2

import 'package:http/http.dart' as http;

class PackageInfo {
  final String name;
  final String kind;
  final String current;
  final String upgradable;
  final String resolvable;
  final String latest;

  PackageInfo({
    required this.name,
    required this.kind,
    required this.current,
    required this.upgradable,
    required this.resolvable,
    required this.latest,
  });
}

class VersionChangelog {
  final String version;
  final String excerpt;
  VersionChangelog(this.version, this.excerpt);
}

const _changelogMaxChars = 400;
const _changelogMaxLines = 6;

String? extractVersion(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) return value['version']?.toString();
  return null;
}

List<PackageInfo> parseOutdatedPackages(Map<String, dynamic> data, bool directOnly) {
  final packages = (data['packages'] as List<dynamic>?) ?? [];
  final outdated = <PackageInfo>[];
  for (final p in packages) {
    final map = p as Map<String, dynamic>;
    final name = map['package'] as String? ?? '';
    final kind = map['kind'] as String? ?? 'transitive';
    final current = extractVersion(map['current']);
    final latest = extractVersion(map['latest']);
    final resolvable = extractVersion(map['resolvable']);
    final upgradable = extractVersion(map['upgradable']);
    if (name.isEmpty || latest == null || latest == '-') continue;
    if (current == latest) continue;
    if (directOnly && kind == 'transitive') continue;
    outdated.add(PackageInfo(
      name: name,
      kind: kind,
      current: current ?? '-',
      upgradable: upgradable ?? '-',
      resolvable: resolvable ?? '-',
      latest: latest,
    ));
  }
  return outdated;
}

Future<List<VersionChangelog>> fetchChangelogsForNewerVersions(
  String packageName,
  String currentVersion,
  String latestVersion,
) async {
  try {
    final url = Uri.parse('https://pub.dev/api/packages/$packageName/feed.atom');
    final response = await http.get(url).timeout(
          const Duration(seconds: 5),
          onTimeout: () => http.Response('', 408),
        );
    if (response.statusCode != 200) return [];
    return parseAllChangelogsFromAtom(response.body, currentVersion);
  } catch (_) {
    return [];
  }
}

List<VersionChangelog> parseAllChangelogsFromAtom(String xml, String currentVersion) {
  const entryStart = '<entry>';
  const entryEnd = '</entry>';
  final result = <VersionChangelog>[];
  var searchFrom = 0;
  final onlyLatest = currentVersion == '-';

  while (true) {
    final entryStartIdx = xml.indexOf(entryStart, searchFrom);
    if (entryStartIdx < 0) break;
    final entryEndIdx = xml.indexOf(entryEnd, entryStartIdx);
    if (entryEndIdx < 0) break;
    final entryXml = xml.substring(entryStartIdx, entryEndIdx + entryEnd.length);

    final version = extractVersionFromEntry(entryXml);
    if (version == null) {
      searchFrom = entryEndIdx + entryEnd.length;
      continue;
    }
    if (onlyLatest) {
      if (result.isNotEmpty) break;
    } else if (versionCompare(version, currentVersion) <= 0) {
      searchFrom = entryEndIdx + entryEnd.length;
      continue;
    }
    final excerpt = extractChangelogExcerptFromEntry(entryXml);
    if (excerpt != null && excerpt.isNotEmpty) {
      result.add(VersionChangelog(version, excerpt));
      if (onlyLatest) break;
    }
    searchFrom = entryEndIdx + entryEnd.length;
  }
  if (!onlyLatest) result.sort((a, b) => versionCompare(a.version, b.version));
  return result;
}

String? extractVersionFromEntry(String entryXml) {
  final titleMatch = RegExp(r'<title>v?([\d.]+(?:[+-][\w.]+)?)\s+of\s+').firstMatch(entryXml);
  if (titleMatch != null) return titleMatch[1];
  final contentMatch = RegExp(r'^(\d+\.\d+\.\d+(?:[+-][\w.]+)?)\s+was\s+published')
      .firstMatch(entryXml.replaceAll(RegExp(r'\s+'), ' '));
  return contentMatch?[1];
}

String? extractChangelogExcerptFromEntry(String entryXml) {
  const contentStart = '<content';
  final contentTagStart = entryXml.indexOf(contentStart);
  if (contentTagStart < 0) return null;
  final openBracket = entryXml.indexOf('>', contentTagStart) + 1;
  final contentEnd = entryXml.indexOf('</content>', openBracket);
  if (contentEnd < 0) return null;
  final rawContent = entryXml.substring(openBracket, contentEnd);
  final decoded = decodeHtmlEntities(rawContent);
  const marker = 'Changelog excerpt:';
  final markerIdx = decoded.indexOf(marker);
  if (markerIdx < 0) return null;
  var excerpt = decoded.substring(markerIdx + marker.length).trim().replaceAll(RegExp(r'\s+'), ' ');
  if (excerpt.length > _changelogMaxChars) {
    excerpt = '${excerpt.substring(0, _changelogMaxChars)}...';
  }
  return excerpt;
}

int versionCompare(String a, String b) {
  final aParts = parseVersionParts(a);
  final bParts = parseVersionParts(b);
  for (var i = 0; i < 3; i++) {
    if (aParts[i] < bParts[i]) return -1;
    if (aParts[i] > bParts[i]) return 1;
  }
  return 0;
}

List<int> parseVersionParts(String v) {
  final base = v.split(RegExp('[+-]')).firstOrNull ?? v;
  final parts = base.split('.').map((x) => int.tryParse(x) ?? 0).toList();
  return [
    if (parts.isNotEmpty) parts[0] else 0,
    if (parts.length > 1) parts[1] else 0,
    if (parts.length > 2) parts[2] else 0,
  ];
}

String decodeHtmlEntities(String s) {
  return s
      .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m[1]!)))
      .replaceAllMapped(
          RegExp('&#x([0-9a-fA-F]+);'), (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)))
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"');
}

List<String> wrapChangeprint(String text, {int maxWidth = 65}) {
  final words = text.split(' ');
  final lines = <String>[];
  var current = '';
  for (final w in words) {
    if (current.isEmpty) {
      current = w;
    } else if ((current.length + 1 + w.length) <= maxWidth) {
      current = '$current $w';
    } else {
      lines.add(current);
      current = w;
    }
  }
  if (current.isNotEmpty) lines.add(current);
  return lines.length > _changelogMaxLines ? lines.take(_changelogMaxLines).toList() : lines;
}

Future<void> printPackageReport(
  List<PackageInfo> packages,
  bool includeLinks,
  bool fetchChangelogs,
) async {
  final direct = packages.where((p) => p.kind == 'direct').toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  final dev = packages.where((p) => p.kind == 'dev').toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  final transitive = packages.where((p) => p.kind == 'transitive').toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  const w = 70;
  print('┌${'─' * (w - 1)}┐');
  print('${'│  PACKAGE UPDATES & CHANGELOGS'.padRight(w - 1)}│');
  print('├${'─' * (w - 1)}┤');
  final pkgCount =
      '${packages.length} package${packages.length == 1 ? '' : 's'} with newer versions';
  print('${'│  $pkgCount'.padRight(w - 1)}│');
  print('└${'─' * (w - 1)}┘');
  print('');

  Future<void> printSection(String title, List<PackageInfo> items) async {
    if (items.isEmpty) return;
    print('── $title ──');
    for (final p in items) {
      print('');
      print('  📦 ${p.name}');
      print('     ${p.current} → ${p.latest}');
      if (fetchChangelogs) {
        final changelogs = await fetchChangelogsForNewerVersions(p.name, p.current, p.latest);
        for (final vc in changelogs) {
          print('     v${vc.version}:');
          for (final line in wrapChangeprint(vc.excerpt)) {
            print('       $line');
          }
        }
      }
      if (p.resolvable != p.current && p.resolvable != '-') {
        print('     Resolvable: ${p.resolvable} (run: flutter pub upgrade)');
      }
      if (includeLinks) {
        print('     Changelog: https://pub.dev/packages/${p.name}/changelog');
      }
    }
    print('');
  }

  await printSection('direct dependencies', direct);
  await printSection('dev_dependencies', dev);
  await printSection('transitive dependencies', transitive);
  print('────────────────────────────────────────────────────────────');
  print('Tip: Run `flutter pub upgrade` to update within pubspec constraints.');
  print('────────────────────────────────────────────────────────────');
}
