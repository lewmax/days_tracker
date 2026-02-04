import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/country_flag_utils.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:days_tracker/presentation/blocs/visit_details/visit_details.dart';
import 'package:days_tracker/presentation/common/bloc/screen_bloc_provider_stateless.dart';
import 'package:days_tracker/presentation/common/widgets/widgets.dart';
import 'package:days_tracker/presentation/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Screen showing details of a single visit.
@RoutePage()
base class VisitDetailsScreen
    extends ScreenBlocProviderStateless<VisitDetailsBloc, VisitDetailsState> {
  final String id;

  const VisitDetailsScreen({super.key, @PathParam('id') required this.id});

  @override
  VisitDetailsBloc createBloc() {
    final bloc = locator<VisitDetailsBloc>();
    bloc.add(VisitDetailsEvent.load(id));
    return bloc;
  }

  @override
  Widget buildScreen(BuildContext context, VisitDetailsBloc bloc) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.visitDetails),
        actions: [
          blocBuilder(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (_) => IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.router.push(EditVisitRoute(id: id)),
                ),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: blocBuilder(
        builder: (context, state) {
          return state.when(
            initial: () => LoadingIndicator(message: context.l10n.loadingVisit),
            loading: () => LoadingIndicator(message: context.l10n.loadingVisit),
            loaded: (visit) => _VisitDetailsContent(visit: visit),
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () => bloc.add(const VisitDetailsEvent.retry()),
            ),
          );
        },
      ),
    );
  }
}

class _VisitDetailsContent extends StatelessWidget {
  final Visit visit;

  const _VisitDetailsContent({required this.visit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    CountryFlagUtils.getCountryFlag(visit.city?.country?.countryCode ?? 'XX'),
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.city?.cityName ?? context.l10n.unknownCity,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visit.city?.country?.countryName ?? context.l10n.unknownCountry,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (visit.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 12, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.activeVisit,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: Icons.calendar_today,
            label: context.l10n.startDate,
            value: DateFormat('MMMM d, yyyy').format(visit.startDate),
          ),
          if (visit.endDate != null)
            _DetailRow(
              icon: Icons.event,
              label: context.l10n.endDate,
              value: DateFormat('MMMM d, yyyy').format(visit.endDate!),
            ),
          _DetailRow(
            icon: Icons.timelapse,
            label: context.l10n.duration,
            value: context.l10n.daysCount(visit.daysCount),
          ),
          _DetailRow(
            icon: visit.source == VisitSource.auto ? Icons.gps_fixed : Icons.edit,
            label: context.l10n.source,
            value: visit.source == VisitSource.auto ? context.l10n.sourceAuto : context.l10n.sourceManual,
          ),
          _DetailRow(
            icon: Icons.update,
            label: context.l10n.lastUpdated,
            value: DateFormat('MMM d, yyyy HH:mm').format(visit.lastUpdated),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.outline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
