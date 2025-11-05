import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/di/locator.dart';
import 'package:days_tracker/presentation/common/widgets/error_widget.dart';
import 'package:days_tracker/presentation/common/widgets/loading_widget.dart';
import 'package:days_tracker/presentation/settings/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<SettingsBloc>()..add(const SettingsEvent.loadSettings()),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          state.maybeWhen(
            dataExported: (jsonData) {
              // Share the exported data
              Share.share(
                jsonData,
                subject: 'DaysTracker Data Export',
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const LoadingWidget(),
            loading: () => const LoadingWidget(),
            loaded: (
              backgroundTracking,
              mapboxToken,
              trackingFrequency,
              languageCode,
            ) =>
                _buildSettings(
              context,
              backgroundTracking,
              mapboxToken,
              trackingFrequency,
              languageCode,
            ),
            dataExported: (_) => const LoadingWidget(),
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                context
                    .read<SettingsBloc>()
                    .add(const SettingsEvent.loadSettings());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettings(
    BuildContext context,
    bool backgroundTracking,
    String mapboxToken,
    int trackingFrequency,
    String languageCode,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          context,
          title: 'Location Tracking',
          children: [
            SwitchListTile(
              title: const Text('Background Tracking'),
              subtitle: const Text('Track location every hour'),
              value: backgroundTracking,
              onChanged: (_) {
                context
                    .read<SettingsBloc>()
                    .add(const SettingsEvent.toggleBackgroundTracking());
              },
            ),
            ListTile(
              title: const Text('Tracking Frequency'),
              subtitle: Text('$trackingFrequency minutes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showFrequencyDialog(context, trackingFrequency),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: 'Mapbox Configuration',
          children: [
            ListTile(
              title: const Text('API Token'),
              subtitle: Text(
                mapboxToken.isEmpty
                    ? 'Not configured'
                    : '${mapboxToken.substring(0, 10)}...',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _showMapboxTokenDialog(context, mapboxToken),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: 'Data Management',
          children: [
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Export all visits as JSON'),
              leading: const Icon(Icons.upload),
              onTap: () {
                context
                    .read<SettingsBloc>()
                    .add(const SettingsEvent.exportData());
              },
            ),
            ListTile(
              title: const Text('Import Data'),
              subtitle: const Text('Import visits from JSON'),
              leading: const Icon(Icons.download),
              onTap: () => _showImportDialog(context),
            ),
            ListTile(
              title: const Text('Delete All Data'),
              subtitle: const Text('Permanently delete all visits'),
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: 'Privacy',
          children: [
            ListTile(
              title: const Text('Privacy Notice'),
              leading: const Icon(Icons.privacy_tip),
              onTap: () => _showPrivacyNotice(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: 'About',
          children: [
            const ListTile(
              title: Text('Version'),
              subtitle: Text(AppConstants.appVersion),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showMapboxTokenDialog(BuildContext context, String currentToken) {
    final controller = TextEditingController(text: currentToken);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mapbox API Token'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Token',
            hintText: 'pk.ey...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.updateMapboxToken(controller.text));
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFrequencyDialog(BuildContext context, int currentFrequency) {
    int selectedFrequency = currentFrequency;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tracking Frequency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$selectedFrequency minutes'),
              Slider(
                value: selectedFrequency.toDouble(),
                min: AppConstants.minTrackingFrequencyMinutes.toDouble(),
                max: AppConstants.maxTrackingFrequencyMinutes.toDouble(),
                divisions: 7,
                label: '$selectedFrequency min',
                onChanged: (value) {
                  setState(() {
                    selectedFrequency = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsBloc>().add(
                    SettingsEvent.updateTrackingFrequency(selectedFrequency));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Data'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Paste JSON data',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(SettingsEvent.importData(controller.text));
              Navigator.pop(dialogContext);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to permanently delete all your visits and location data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SettingsBloc>()
                  .add(const SettingsEvent.deleteAllData());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Notice'),
        content: const SingleChildScrollView(
          child: Text(AppConstants.privacyNotice),
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
}
