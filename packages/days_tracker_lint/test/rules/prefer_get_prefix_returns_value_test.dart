
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:days_tracker_lint/src/rules/prefer_get_prefix_returns_value.dart';
import 'package:test/test.dart';

import '../utils/test_utils.dart';

void main() {
  group('PreferGetPrefixReturnsValue', () {
    test('flags get* methods that return void', () async {
      const rule = PreferGetPrefixReturnsValue();

      final file = writeToTemporaryFile('''
class C {
  void getFoo() {}
  int getBar() => 0;
  void get() {}
}
''');
      final result = await resolveFile(path: file.path) as ResolvedUnitResult;

      final errors = await rule.testRun(result);

      expect(errors, hasLength(1));
      expect(errors.first.diagnosticCode.name, 'prefer_get_prefix_returns_value');
      expect(errors.first.message, contains('get*'));
      // Lint should be on getFoo
      expect(file.readAsStringSync().substring(errors.first.offset).startsWith('getFoo'), isTrue);
    });

    test('does not flag get* methods that return non-void', () async {
      const rule = PreferGetPrefixReturnsValue();

      final file = writeToTemporaryFile('''
class C {
  int getValue() => 42;
  String getUrl() => 'https://';
}
''');
      final result = await resolveFile(path: file.path) as ResolvedUnitResult;

      final errors = await rule.testRun(result);

      expect(errors, isEmpty);
    });
  });
}
