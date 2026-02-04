import 'package:flutter/material.dart';

/// Widget for displaying empty state with icon, message, and optional CTA.
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The main message.
  final String message;

  /// Optional subtitle message.
  final String? subtitle;

  /// Optional button text.
  final String? buttonText;

  /// Optional callback when button is pressed.
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: subtitle != null ? '$message. $subtitle' : message,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: theme.colorScheme.outline, semanticLabel: ''),
              const SizedBox(height: 24),
              Text(message, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
              ],
              if (buttonText != null && onButtonPressed != null) ...[
                const SizedBox(height: 32),
                Semantics(
                  button: true,
                  label: buttonText,
                  child: FilledButton(onPressed: onButtonPressed, child: Text(buttonText!)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
