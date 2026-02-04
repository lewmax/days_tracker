import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_bloc.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_event.dart';
import 'package:days_tracker/presentation/blocs/settings/settings_state.dart';
import 'package:days_tracker/presentation/common/bloc/bloced_widget.dart';
import 'package:days_tracker/presentation/common/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Settings screen for app configuration.
@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<SettingsBloc>()..add(const SettingsEvent.loadSettings()),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends BlocedWidget<SettingsBloc, SettingsState> {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: blocBuilder(
        builder: (context, state) {
          return state.when(
            initial: () => const LoadingIndicator(),
            loading: () => LoadingIndicator(message: context.l10n.loadingSettings),
            loaded:
                (
                  dayCountingRule,
                  backgroundTracking,
                  hasApiKey,
                  isTrackingLocation,
                  isExporting,
                  isImporting,
                  lastLocationResult,
                  exportedData,
                  importMessage,
                ) {
                  // Show snackbar for import messages
                  if (importMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(importMessage)));
                    });
                  }

                  // Handle exported data
                  if (exportedData != null && !isExporting) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _shareExportedData(context, exportedData);
                    });
                  }

                  return ListView(
                    children: [
                      // Location Tracking Section
                      _SectionHeader(title: context.l10n.locationTracking),
                      SwitchListTile(
                        title: Text(context.l10n.backgroundTracking),
                        subtitle: Text(context.l10n.backgroundTrackingSubtitle),
                        value: backgroundTracking,
                        onChanged: (value) {
                          blocOf(context).add(SettingsEvent.toggleBackgroundTracking(value));
                        },
                      ),
                      ListTile(
                        title: Text(context.l10n.testLocationNow),
                        subtitle: Text(lastLocationResult ?? context.l10n.testLocationSubtitle),
                        trailing: isTrackingLocation
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        onTap: isTrackingLocation
                            ? null
                            : () {
                                blocOf(context).add(const SettingsEvent.trackLocationNow());
                              },
                      ),
                      const Divider(),

                      // Preferences Section
                      _SectionHeader(title: context.l10n.preferences),
                      ListTile(
                        title: Text(context.l10n.dayCountingRule),
                        subtitle: Text(dayCountingRule == DayCountingRule.anyPresence
                            ? context.l10n.anyPresence
                            : context.l10n.twoOrMorePings),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SegmentedButton<DayCountingRule>(
                          segments: [
                            ButtonSegment(
                              value: DayCountingRule.anyPresence,
                              label: Text(context.l10n.anyPresence),
                            ),
                            ButtonSegment(
                              value: DayCountingRule.twoOrMorePings,
                              label: Text(context.l10n.twoOrMorePings),
                            ),
                          ],
                          selected: {dayCountingRule},
                          onSelectionChanged: (selected) {
                            blocOf(
                              context,
                            ).add(SettingsEvent.changeDayCountingRule(selected.first));
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),

                      // Data Management Section
                      _SectionHeader(title: context.l10n.dataManagement),
                      ListTile(
                        leading: isExporting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        title: Text(context.l10n.exportData),
                        subtitle: Text(context.l10n.exportDataSubtitle),
                        onTap: isExporting
                            ? null
                            : () {
                                blocOf(context).add(const SettingsEvent.exportData());
                              },
                      ),
                      ListTile(
                        leading: isImporting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        title: Text(context.l10n.importData),
                        subtitle: Text(context.l10n.importDataSubtitle),
                        onTap: isImporting ? null : () => _pickAndImportFile(context),
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                        title: Text(
                          context.l10n.clearAllData,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        subtitle: Text(context.l10n.clearAllDataSubtitle),
                        onTap: () async {
                          final confirmed = await ConfirmationDialog.show(
                            context: context,
                            title: context.l10n.clearAllData,
                            content: context.l10n.clearAllDataConfirmMessage,
                            confirmText: context.l10n.deleteEverything,
                            isDestructive: true,
                          );
                          if (confirmed && context.mounted) {
                            blocOf(context).add(const SettingsEvent.clearAllData());
                          }
                        },
                      ),
                      const Divider(),

                      // API Configuration Section
                      _SectionHeader(title: context.l10n.apiConfiguration),
                      ListTile(
                        leading: const Icon(Icons.key),
                        title: Text(context.l10n.googleMapsApiKey),
                        subtitle: Text(hasApiKey ? context.l10n.apiKeyConfigured : context.l10n.apiKeyNotConfigured),
                        trailing: hasApiKey
                            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                            : Icon(Icons.warning, color: theme.colorScheme.error),
                        onTap: () => _showApiKeyDialog(context, hasApiKey),
                      ),
                      const Divider(),

                      // About Section
                      _SectionHeader(title: context.l10n.about),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(context.l10n.version),
                        subtitle: Text(context.l10n.versionNumber),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(context.l10n.privacy),
                        subtitle: Text(context.l10n.privacySubtitle),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: Text(context.l10n.sourceCode),
                        subtitle: Text(context.l10n.viewOnGitHub),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.githubLinkNotConfigured)),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                blocOf(context).add(const SettingsEvent.loadSettings());
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareExportedData(BuildContext context, String data) async {
    final shareSubject = context.l10n.exportShareSubject;
    try {
      // Create temp file for sharing
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/daystracker_export_$timestamp.json');
      await file.writeAsString(data);

      // Share the file
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: shareSubject),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedToShareExport(e.toString()))),
        );
      }
    }
  }

  Future<void> _pickAndImportFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      String? content;

      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      }

      if (content == null || content.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.fileEmptyOrUnreadable)),
          );
        }
        return;
      }

      // Show confirmation dialog
      if (!context.mounted) return;
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: context.l10n.importData,
        content: context.l10n.importConfirmMessage,
        confirmText: context.l10n.confirmImport,
        isDestructive: true,
      );

      if (confirmed && context.mounted) {
        blocOf(context).add(SettingsEvent.importData(content));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedToReadFile(e.toString()))),
        );
      }
    }
  }

  void _showApiKeyDialog(BuildContext context, bool hasKey) {
    final controller = TextEditingController();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.googleMapsApiKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.apiKeyDialogDescription),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.apiKeyLabel,
                hintText: l10n.apiKeyHint,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          if (hasKey)
            TextButton(
              onPressed: () {
                blocOf(context).add(const SettingsEvent.clearApiKey());
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.remove, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                blocOf(context).add(SettingsEvent.setApiKey(controller.text));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.apiKeySaved)),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
