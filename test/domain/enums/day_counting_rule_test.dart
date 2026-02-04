import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayCountingRule', () {
    test('should have correct descriptions', () {
      expect(DayCountingRule.anyPresence.description, 'Any Presence');
      expect(DayCountingRule.twoOrMorePings.description, '2+ Pings');
    });

    test('should have correct explanations', () {
      expect(
        DayCountingRule.anyPresence.explanation,
        'Any location ping in a day counts as a full day',
      );
      expect(
        DayCountingRule.twoOrMorePings.explanation,
        'At least 2 pings required to count as a day',
      );
    });

    test('should have exactly 2 values', () {
      expect(DayCountingRule.values.length, 2);
    });
  });
}
