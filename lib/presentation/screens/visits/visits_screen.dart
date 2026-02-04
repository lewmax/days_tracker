import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/country_flag_utils.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/domain/enums/visits_view_mode.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_bloc.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_event.dart';
import 'package:days_tracker/presentation/blocs/visits/visits_state.dart';
import 'package:days_tracker/presentation/common/bloc/bloced_widget.dart';
import 'package:days_tracker/presentation/common/widgets/widgets.dart';
import 'package:days_tracker/presentation/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main screen displaying all visits.
@RoutePage()
class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<VisitsBloc>()..add(const VisitsEvent.loadVisits()),
      child: const _VisitsScreenContent(),
    );
  }
}

class _VisitsScreenContent extends BlocedWidget<VisitsBloc, VisitsState> {
  const _VisitsScreenContent() : super(key: null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myVisits),
        actions: [
          blocBuilder(
            builder: (context, state) {
              return PopupMenuButton<VisitsViewMode>(
                icon: const Icon(Icons.sort),
                tooltip: context.l10n.viewMode,
                onSelected: (mode) {
                  blocOf(context).add(VisitsEvent.changeViewMode(mode));
                },
                itemBuilder: (context) => VisitsViewMode.values.map((mode) {
                  final isSelected = state.maybeMap(
                    loaded: (s) => s.viewMode == mode,
                    orElse: () => false,
                  );
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
            loading: () => LoadingIndicator(message: context.l10n.loadingVisits),
            loaded: (visits, filteredVisits, viewMode, filterQuery, activeVisit) {
              if (filteredVisits.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.flight_takeoff,
                  message: context.l10n.noVisitsYet,
                  subtitle: context.l10n.noVisitsSubtitle,
                  buttonText: context.l10n.addVisit,
                  onButtonPressed: () => context.router.push(const AddVisitRoute()),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  blocOf(context).add(const VisitsEvent.refreshVisits());
                },
                child: _VisitsList(visits: filteredVisits, viewMode: viewMode),
              );
            },
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                blocOf(context).add(const VisitsEvent.loadVisits());
              },
            ),
          );
        },
      ),
      floatingActionButton: Semantics(
        button: true,
        label: context.l10n.addVisitSemanticLabel,
        child: FloatingActionButton(
          onPressed: () => context.router.push(const AddVisitRoute()),
          child: const Icon(Icons.add, semanticLabel: ''),
        ),
      ),
    );
  }
}

class _VisitsList extends StatelessWidget {
  final List<Visit> visits;
  final VisitsViewMode viewMode;

  const _VisitsList({required this.visits, required this.viewMode});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return _VisitListItem(visit: visit);
      },
    );
  }
}

class _VisitListItem extends StatelessWidget {
  final Visit visit;

  const _VisitListItem({required this.visit});

  String _formatDateRange(BuildContext context) {
    final start = visit.startDate;
    final end = visit.endDate;

    final startStr = '${_monthName(start.month)} ${start.day}';

    if (end == null) {
      return context.l10n.activeSince(startStr);
    }

    final endStr = '${_monthName(end.month)} ${end.day}';

    if (start.year != end.year) {
      return '$startStr, ${start.year} - $endStr, ${end.year}';
    }

    return '$startStr - $endStr';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countryCode = visit.city?.country?.countryCode ?? 'XX';
    final flag = CountryFlagUtils.getCountryFlag(countryCode);
    final cityName = visit.city?.cityName ?? context.l10n.unknownCity;
    final countryName = visit.city?.country?.countryName ?? context.l10n.unknownCountry;

    return Dismissible(
      key: Key(visit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return ConfirmationDialog.show(
          context: context,
          title: context.l10n.deleteVisit,
          content: context.l10n.deleteVisitConfirm(cityName),
          confirmText: context.l10n.delete,
          isDestructive: true,
        );
      },
      onDismissed: (direction) {
        context.read<VisitsBloc>().add(VisitsEvent.deleteVisit(visit.id));
      }, // blocOf not available in _VisitListItem, keep context.read
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () => context.router.push(VisitDetailsRoute(id: visit.id)),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        countryName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                          Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateRange(context),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: visit.isActive
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        context.l10n.daysCount(visit.daysCount),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: visit.isActive
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      visit.source == VisitSource.auto ? Icons.gps_fixed : Icons.edit,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
