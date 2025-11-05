import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/locator.dart';
import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/presentation/common/widgets/error_widget.dart';
import 'package:days_tracker/presentation/common/widgets/loading_widget.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_bloc.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_event.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_state.dart';
import 'package:days_tracker/presentation/visits/widgets/add_visit_dialog.dart';
import 'package:days_tracker/presentation/visits/widgets/visit_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<VisitsBloc>()..add(const VisitsEvent.loadVisits()),
      child: const _VisitsScreenContent(),
    );
  }
}

class _VisitsScreenContent extends StatelessWidget {
  const _VisitsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context
                  .read<VisitsBloc>()
                  .add(const VisitsEvent.refreshLocation());
            },
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: BlocBuilder<VisitsBloc, VisitsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const LoadingWidget(),
            loading: () => const LoadingWidget(),
            loaded: (visits, activeVisit) => _buildVisitsList(
              context,
              visits,
              activeVisit,
            ),
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                context.read<VisitsBloc>().add(const VisitsEvent.loadVisits());
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVisitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVisitsList(
    BuildContext context,
    List<Visit> visits,
    Visit? activeVisit,
  ) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No visits yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a visit\nor use location tracking',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visits.length + (activeVisit != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && activeVisit != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Active Visit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              VisitItem(
                visit: activeVisit,
                isActive: true,
                onTap: () => _showVisitDetails(context, activeVisit),
                onDelete: () => _deleteVisit(context, activeVisit.id),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Past Visits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          );
        }

        final visitIndex = activeVisit != null ? index - 1 : index;
        final visit = visits[visitIndex];

        return VisitItem(
          visit: visit,
          onTap: () => _showVisitDetails(context, visit),
          onDelete: () => _deleteVisit(context, visit.id),
        );
      },
    );
  }

  void _showAddVisitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<VisitsBloc>(),
        child: const AddVisitDialog(),
      ),
    );
  }

  void _showVisitDetails(BuildContext context, Visit visit) {
    // TODO: Navigate to visit details/edit screen
    // For now, just show a dialog with details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(CountryUtils.getCountryName(visit.countryCode)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visit.city != null) ...[
              Text('City: ${visit.city}'),
              const SizedBox(height: 8),
            ],
            Text(
                'Start: ${AppDateUtils.standardDateFormat.format(visit.startDate)}'),
            if (visit.endDate != null)
              Text(
                  'End: ${AppDateUtils.standardDateFormat.format(visit.endDate!)}'),
            const SizedBox(height: 8),
            Text(
                'Coordinates: ${visit.latitude.toStringAsFixed(4)}, ${visit.longitude.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteVisit(BuildContext context, String visitId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Visit'),
        content: const Text('Are you sure you want to delete this visit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<VisitsBloc>().add(VisitsEvent.deleteVisit(visitId));
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
