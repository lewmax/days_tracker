import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A text field that opens a date range picker when tapped.
class DateRangePickerField extends StatelessWidget {
  /// The selected start date.
  final DateTime? startDate;

  /// The selected end date (null for active/ongoing).
  final DateTime? endDate;

  /// Callback when dates are selected.
  final void Function(DateTime start, DateTime? end) onDatesSelected;

  /// Label for the field.
  final String label;

  /// Whether end date is required.
  final bool endDateRequired;

  /// Hint text when no dates are selected.
  final String? hintText;

  /// Error text to display.
  final String? errorText;

  const DateRangePickerField({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDatesSelected,
    this.label = 'Date Range',
    this.endDateRequired = false,
    this.hintText,
    this.errorText,
  });

  String _formatDateRange() {
    if (startDate == null) return '';

    final dateFormat = DateFormat('MMM d, yyyy');
    final startFormatted = dateFormat.format(startDate!);

    if (endDate == null) {
      return 'From $startFormatted (ongoing)';
    }

    return '$startFormatted - ${dateFormat.format(endDate!)}';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(2000);
    final lastDate = DateTime(now.year + 10);

    // First, pick start date
    final start = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select start date',
    );

    if (start == null || !context.mounted) return;

    // Then ask if user wants to set end date
    final setEndDate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set end date?'),
        content: const Text('Leave empty for an active/ongoing visit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No end date'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Set end date'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (setEndDate == true) {
      final end = await showDatePicker(
        context: context,
        initialDate: endDate ?? start,
        firstDate: start,
        lastDate: lastDate,
        helpText: 'Select end date',
      );

      onDatesSelected(start, end);
    } else {
      onDatesSelected(start, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _formatDateRange()),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Tap to select dates',
        errorText: errorText,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
      ),
      onTap: () => _selectDateRange(context),
    );
  }
}
