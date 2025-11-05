import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:days_tracker/domain/entities/visit_summary.dart';
import 'package:days_tracker/domain/usecases/calculate_visit_summary.dart';
import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class HomeWidgetService {
  final CalculateVisitSummary _calculateVisitSummary;
  final Logger _logger = Logger();

  HomeWidgetService(
    this._calculateVisitSummary,
  );

  /// Update home widget with latest visit stats
  Future<void> updateWidget() async {
    try {
      _logger.i('Updating home widget');

      // Get summary for current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month);

      final summaries = await _calculateVisitSummary.execute(
        startDate: startOfMonth,
        endDate: now,
        rule: DayCountingRule.anyPresence,
      );

      // Get top 3 countries/cities
      final top3 = summaries.take(3).toList();

      // Format data for widget
      final widgetData = _formatWidgetData(top3);

      // Update widget
      await HomeWidget.saveWidgetData<String>('widget_data', widgetData);
      await HomeWidget.updateWidget(
        name: 'DaysTrackerWidget',
        iOSName: 'DaysTrackerWidget',
        androidName: 'DaysTrackerWidget',
      );

      _logger.i('Home widget updated successfully');
    } catch (e) {
      _logger.e('Failed to update home widget: $e');
    }
  }

  String _formatWidgetData(List<VisitSummary> summaries) {
    if (summaries.isEmpty) {
      return 'No visits this month';
    }

    final lines = summaries.map((summary) {
      final countryName = CountryUtils.getCountryName(summary.countryCode);
      final location =
          summary.city != null ? '${summary.city}, $countryName' : countryName;
      return '$location: ${summary.totalDays} days';
    }).join('\n');

    return lines;
  }

  /// Register background callback for widget
  static Future<void> registerBackgroundCallback() async {
    try {
      await HomeWidget.registerBackgroundCallback(backgroundCallback);
    } catch (e) {
      Logger().e('Failed to register widget background callback: $e');
    }
  }

  /// Background callback for widget interactions
  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    try {
      Logger().i('Widget background callback triggered: $uri');

      // TODO: Handle widget interactions
      // For example, open specific screen when widget is tapped
    } catch (e) {
      Logger().e('Widget background callback failed: $e');
    }
  }
}
