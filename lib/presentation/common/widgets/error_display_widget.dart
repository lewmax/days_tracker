import 'package:flutter/material.dart';

/// Widget for displaying error messages with an optional retry button.
class ErrorDisplayWidget extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Optional callback when retry button is pressed.
  final VoidCallback? onRetry;

  /// Optional icon to display.
  final IconData icon;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Error: $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.error, semanticLabel: 'Error'),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  label: 'Retry',
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, semanticLabel: ''),
                    label: const Text('Retry'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
