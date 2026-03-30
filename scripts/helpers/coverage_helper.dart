// @dart=3.2

import 'dart:io';

const _excludePattern = r'\.g\.dart|\.freezed\.dart|/l10n/|/generated/|/theme/';
const _minCoveragePercent = 75;

/// Parses lcov.info and returns (totalLf, totalLh) or null if no data.
(int, int)? parseLcov(String lcovPath) {
  final file = File(lcovPath);
  if (!file.existsSync()) return null;

  final pattern = RegExp(_excludePattern);
  var totalLf = 0;
  var totalLh = 0;
  String? currentFile;
  var fileLf = 0;

  for (final line in file.readAsStringSync().split('\n')) {
    if (line.startsWith('SF:lib/')) {
      currentFile = line.substring(3);
      fileLf = 0;
    } else if (currentFile != null && line.startsWith('LF:')) {
      if (!pattern.hasMatch(currentFile)) {
        fileLf = int.tryParse(line.substring(3)) ?? 0;
      }
    } else if (currentFile != null && line.startsWith('LH:')) {
      if (!pattern.hasMatch(currentFile)) {
        final lh = int.tryParse(line.substring(3)) ?? 0;
        if (lh > 0) {
          totalLf += fileLf;
          totalLh += lh;
        }
      }
      currentFile = null;
    }
  }

  return (totalLf, totalLh);
}

/// Checks coverage and prints result. Returns true if passes.
bool checkCoverage(String projectRoot, {required void Function(String) onPrint}) {
  final lcovPath = '$projectRoot/coverage/lcov.info';
  final parsed = parseLcov(lcovPath);

  if (parsed == null) {
    onPrint('No coverage data found at $lcovPath');
    return false;
  }

  final (totalLf, totalLh) = parsed;
  if (totalLf <= 0) {
    onPrint('No coverage data');
    return false;
  }

  final coverage = (100 * totalLh / totalLf).toStringAsFixed(1);
  onPrint('Coverage (excl. generated/l10n/theme): $coverage% ($totalLh/$totalLf lines)');

  if (totalLh < (totalLf * _minCoveragePercent / 100)) {
    onPrint('Coverage is below $_minCoveragePercent%');
    return false;
  }
  return true;
}
