// @dart=3.2

import 'dart:convert';

class LintIssue {
  final String code;
  final String severity;
  final String message;
  final String file;
  final int line;
  final int column;
  final String relativePath;

  LintIssue({
    required this.code,
    required this.severity,
    required this.message,
    required this.file,
    required this.line,
    required this.column,
    required this.relativePath,
  });
}

(Map<String, dynamic>?, int) parseLintOutput(String stdoutStr) {
  Map<String, dynamic>? data;
  try {
    data = jsonDecode(stdoutStr) as Map<String, dynamic>?;
  } catch (_) {
    return (null, 1);
  }
  return (data, 0);
}

List<LintIssue> parseDiagnostics(Map<String, dynamic> data, String projectRoot) {
  final diagnostics = (data['diagnostics'] as List<dynamic>?) ?? [];
  final issues = <LintIssue>[];
  for (final d in diagnostics) {
    final map = d as Map<String, dynamic>;
    final loc = map['location'] as Map<String, dynamic>?;
    final file = (loc?['file'] as String?) ?? '';
    final range = loc?['range'] as Map<String, dynamic>?;
    final start = range?['start'] as Map<String, dynamic>?;
    final line = (start?['line'] as num?)?.toInt() ?? 0;
    final col = (start?['column'] as num?)?.toInt() ?? 0;
    issues.add(LintIssue(
      code: map['code'] as String? ?? '',
      severity: map['severity'] as String? ?? 'INFO',
      message: map['problemMessage'] as String? ?? '',
      file: file,
      line: line,
      column: col,
      relativePath: relativePath(file, projectRoot),
    ));
  }
  return issues;
}

String relativePath(String path, String root) {
  final normalized = path.replaceAll(r'\', '/');
  final rootNorm = root.replaceAll(r'\', '/').replaceFirst(RegExp(r'/$'), '');
  if (normalized.startsWith('$rootNorm/')) return normalized.substring(rootNorm.length + 1);
  final libIdx = normalized.indexOf('/lib/');
  if (libIdx >= 0) return normalized.substring(libIdx + 1);
  return path;
}

String inferLayer(String path) {
  if (path.contains('/domain/')) return 'domain';
  if (path.contains('/data/')) return 'data';
  if (path.contains('/presentation/')) return 'presentation';
  if (path.contains('/core/')) return 'core';
  return 'other';
}

void printLintReport(List<LintIssue> issues, String projectRoot) {
  final byRule = <String, List<LintIssue>>{};
  final byLayer = <String, List<LintIssue>>{};
  final bySeverity = <String, int>{};

  for (final i in issues) {
    byRule.putIfAbsent(i.code, () => []).add(i);
    byLayer.putIfAbsent(inferLayer(i.relativePath), () => []).add(i);
    bySeverity[i.severity] = (bySeverity[i.severity] ?? 0) + 1;
  }

  final sortedRules = byRule.keys.toList()
    ..sort((a, b) => byRule[b]!.length.compareTo(byRule[a]!.length));

  const w = 61;
  print('');
  print('┌${'─' * (w - 1)}┐');
  print('${'│  LINT REPORT'.padRight(w)}│');
  print('├${'─' * (w - 1)}┤');
  print('${'│  Total issues: ${issues.length.toString().padLeft(3)}'.padRight(w)}│');
  print('├${'─' * (w - 1)}┤');
  print('${'│  BY RULE'.padRight(w)}│');
  for (final rule in sortedRules) {
    final count = byRule[rule]!.length;
    final label = rule.length > 42 ? '${rule.substring(0, 39)}...' : rule;
    print('${'│    $label ${count.toString().padLeft(3)}'.padRight(w)}│');
  }
  print('├${'─' * (w - 1)}┤');
  print('${'│  BY LAYER'.padRight(w)}│');
  for (final layer in ['domain', 'data', 'presentation', 'core', 'other']) {
    final count = byLayer[layer]?.length ?? 0;
    if (count > 0) {
      print('${'│    ${layer.padRight(12)} ${count.toString().padLeft(3)}'.padRight(w)}│');
    }
  }
  final sevStr = bySeverity.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  print('├${'─' * (w - 1)}┤');
  print('${'│  Severity: $sevStr'.padRight(w)}│');
  print('└${'─' * (w - 1)}┘');
  print('');

  print('────────────────────────────────────────────────────────────');
  print('ISSUES BY RULE');
  print('────────────────────────────────────────────────────────────');
  for (final rule in sortedRules) {
    final ruleIssues = byRule[rule]!;
    final uniqueFiles = ruleIssues.map((i) => i.relativePath).toSet().length;
    print('');
    print(
        '  $rule (${ruleIssues.length} issue${ruleIssues.length == 1 ? '' : 's'}, $uniqueFiles file${uniqueFiles == 1 ? '' : 's'})');
    print('  ${'─' * 60}');
    final byFile = <String, List<LintIssue>>{};
    for (final i in ruleIssues) {
      byFile.putIfAbsent(i.relativePath, () => []).add(i);
    }
    for (final file in byFile.keys.toList()..sort()) {
      for (final i in byFile[file]!) {
        final shortMsg = i.message.length > 55 ? '${i.message.substring(0, 52)}...' : i.message;
        print('    $file:${i.line}:${i.column}');
        print('      → $shortMsg');
      }
    }
  }
  print('');
  print('────────────────────────────────────────────────────────────');
  print('${issues.length} issue${issues.length == 1 ? '' : 's'} found.');
  print('────────────────────────────────────────────────────────────');
}
