import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/di/locator.dart';
import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:days_tracker/domain/entities/visit_summary.dart';
import 'package:days_tracker/presentation/common/widgets/error_widget.dart';
import 'package:days_tracker/presentation/common/widgets/loading_widget.dart';
import 'package:days_tracker/presentation/summary/bloc/summary_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateRange = AppDateUtils.getLastNDays(AppConstants.days183);

    return BlocProvider(
      create: (_) => locator<SummaryBloc>()
        ..add(SummaryEvent.loadSummary(
          startDate: dateRange.start,
          endDate: dateRange.end,
        )),
      child: const _SummaryScreenContent(),
    );
  }
}

class _SummaryScreenContent extends StatelessWidget {
  const _SummaryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (days) {
              final dateRange = AppDateUtils.getLastNDays(days);
              context.read<SummaryBloc>().add(
                    SummaryEvent.changePeriod(
                      startDate: dateRange.start,
                      endDate: dateRange.end,
                    ),
                  );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AppConstants.days183,
                child: Text('Last 183 days'),
              ),
              const PopupMenuItem(
                value: AppConstants.days365,
                child: Text('Last 365 days'),
              ),
              const PopupMenuItem(
                value: 30,
                child: Text('Last 30 days'),
              ),
              const PopupMenuItem(
                value: 90,
                child: Text('Last 90 days'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<SummaryBloc, SummaryState>(
        builder: (context, state) {
          return state.when(
            initial: () => const LoadingWidget(),
            loading: () => const LoadingWidget(),
            loaded: (summaries, startDate, endDate, overnightOnly) =>
                _buildSummaryContent(
              context,
              summaries,
              startDate,
              endDate,
              overnightOnly,
            ),
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                final dateRange =
                    AppDateUtils.getLastNDays(AppConstants.days183);
                context.read<SummaryBloc>().add(
                      SummaryEvent.loadSummary(
                        startDate: dateRange.start,
                        endDate: dateRange.end,
                      ),
                    );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryContent(
    BuildContext context,
    List<VisitSummary> summaries,
    DateTime startDate,
    DateTime endDate,
    bool overnightOnly,
  ) {
    if (summaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data for selected period',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    final totalDays = summaries.fold<int>(0, (sum, s) => sum + s.totalDays);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Column(
            children: [
              Text(
                'Period: ${AppDateUtils.standardDateFormat.format(startDate)} - ${AppDateUtils.standardDateFormat.format(endDate)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$totalDays',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              Text(
                'Total Days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Overnight Only'),
                subtitle: const Text('Count only overnight stays'),
                value: overnightOnly,
                onChanged: (_) {
                  context
                      .read<SummaryBloc>()
                      .add(const SummaryEvent.toggleOvernightOnly());
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return _buildSummaryCard(context, summary, totalDays);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    VisitSummary summary,
    int totalDays,
  ) {
    final countryName = CountryUtils.getCountryName(summary.countryCode);
    final percentage =
        totalDays > 0 ? (summary.totalDays / totalDays * 100) : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        countryName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (summary.city != null)
                        Text(
                          summary.city!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${summary.totalDays}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                    ),
                    Text(
                      AppDateUtils.formatDaysCount(summary.totalDays),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}% of total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
