import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/country_flag_utils.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/statistics_view_mode.dart';
import 'package:days_tracker/domain/enums/time_period.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_event.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_state.dart';
import 'package:days_tracker/presentation/common/bloc/bloced_widget.dart';
import 'package:days_tracker/presentation/common/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Main statistics screen with calendar and summary views.
@RoutePage()
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<StatisticsBloc>()..add(const StatisticsEvent.loadStatistics()),
      child: const _StatisticsScreenContent(),
    );
  }
}

class _StatisticsScreenContent extends BlocedWidget<StatisticsBloc, StatisticsState> {
  const _StatisticsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statisticsTitle),
        actions: [
          blocBuilder(
            builder: (context, state) {
              return PopupMenuButton<StatisticsViewMode>(
                icon: const Icon(Icons.view_agenda),
                tooltip: context.l10n.viewMode,
                onSelected: (mode) {
                  blocOf(context).add(StatisticsEvent.changeViewMode(mode));
                },
                itemBuilder: (context) => StatisticsViewMode.values.map((mode) {
                  final isSelected = state.viewModeOrDefault == mode;
                  return PopupMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        else
                          const SizedBox(width: 24),
                        const SizedBox(width: 8),
                        Text(mode.label),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      body: blocBuilder(
        builder: (context, state) {
          return state.when(
            initial: () => LoadingIndicator(message: context.l10n.initializing),
            loading: () => LoadingIndicator(message: context.l10n.loadingStatistics),
            loaded:
                (
                  summary,
                  calendarData,
                  timePeriod,
                  countingRule,
                  viewMode,
                  calendarYear,
                  calendarMonth,
                  selectedDayDetails,
                  selectedDate,
                ) {
                  return Column(
                    children: [
                      // Time period selector
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<TimePeriod>(
                                initialValue: timePeriod,
                                decoration: InputDecoration(
                                  labelText: context.l10n.timePeriodLabel,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: TimePeriod.values.map((period) {
                                  return DropdownMenuItem(value: period, child: Text(period.label));
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    blocOf(context).add(StatisticsEvent.changeTimePeriod(value));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content based on view mode
                      Expanded(
                        child: switch (viewMode) {
                          StatisticsViewMode.calendar => _CalendarView(
                            calendarData: calendarData,
                            year: calendarYear,
                            month: calendarMonth,
                          ),
                          StatisticsViewMode.chronological => _ChronologicalView(summary: summary),
                          StatisticsViewMode.groupedByCountry => _GroupedByCountryView(
                            countryStats: summary.countries,
                          ),
                          StatisticsViewMode.periodSummary => _PeriodSummaryView(summary: summary),
                        },
                      ),
                    ],
                  );
                },
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                blocOf(context).add(const StatisticsEvent.loadStatistics());
              },
            ),
          );
        },
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  final Map<String, List<Country>> calendarData;
  final int year;
  final int month;

  const _CalendarView({required this.calendarData, required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Monday
    final today = DateTime.now();

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  context.read<StatisticsBloc>().add(const StatisticsEvent.previousMonth());
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(firstDayOfMonth),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  context.read<StatisticsBloc>().add(const StatisticsEvent.nextMonth());
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
            ),
            itemCount: 42, // 6 weeks
            itemBuilder: (context, index) {
              final dayOffset = index - (startWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox();
              }

              final day = dayOffset + 1;
              final date = DateTime(year, month, day);
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final countries = calendarData[dateKey] ?? [];
              final isToday =
                  date.year == today.year && date.month == today.month && date.day == today.day;

              return InkWell(
                onTap: () {
                  context.read<StatisticsBloc>().add(StatisticsEvent.selectDate(date));
                  _showDayDetails(context, date, countries);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.colorScheme.primaryContainer
                        : countries.isNotEmpty
                        ? theme.colorScheme.surfaceContainerHighest
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isToday ? FontWeight.bold : null,
                          color: isToday ? theme.colorScheme.onPrimaryContainer : null,
                        ),
                      ),
                      if (countries.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          countries.take(3).map((c) {
                            return CountryFlagUtils.getCountryFlag(c.countryCode);
                          }).join(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        if (countries.length > 3) Text('...', style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, List<Country> countries) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM d, yyyy').format(date),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (countries.isEmpty)
              Text(context.l10n.noVisitsForDay)
            else
              ...countries.map(
                (country) => ListTile(
                  leading: Text(
                    CountryFlagUtils.getCountryFlag(country.countryCode),
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(country.countryName),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ChronologicalView extends StatelessWidget {
  final StatisticsSummary summary;

  const _ChronologicalView({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(context.l10n.chronologicalView, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              context.l10n.totalDaysTracked(summary.totalDays),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedByCountryView extends StatelessWidget {
  final List<CountryStats> countryStats;

  const _GroupedByCountryView({required this.countryStats});

  @override
  Widget build(BuildContext context) {
    if (countryStats.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.flag,
        message: context.l10n.noCountryData,
        subtitle: context.l10n.noCountryDataSubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: countryStats.length,
      itemBuilder: (context, index) {
        final stat = countryStats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(
              CountryFlagUtils.getCountryFlag(stat.country.countryCode),
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(stat.country.countryName),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                context.l10n.daysCount(stat.days),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeriodSummaryView extends StatelessWidget {
  final StatisticsSummary summary;

  const _PeriodSummaryView({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.public, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    '${summary.totalDays}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    context.l10n.daysTracked,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 8),
                  Text(context.l10n.countriesCount(summary.totalCountries), style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Country breakdown
          Text(
            context.l10n.countries,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (summary.countries.isEmpty)
            Text(context.l10n.noCountryDataAvailable)
          else
            ...summary.countries.take(10).map((stat) {
              final percentage = summary.totalDays > 0
                  ? (stat.days / summary.totalDays * 100).toStringAsFixed(1)
                  : '0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      CountryFlagUtils.getCountryFlag(stat.country.countryCode),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat.country.countryName, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: summary.totalDays > 0 ? stat.days / summary.totalDays : 0,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${stat.days}d ($percentage%)', style: theme.textTheme.bodySmall),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
