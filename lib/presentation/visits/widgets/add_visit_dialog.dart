import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_bloc.dart';
import 'package:days_tracker/presentation/visits/bloc/visits_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class AddVisitDialog extends StatefulWidget {
  const AddVisitDialog({super.key});

  @override
  State<AddVisitDialog> createState() => _AddVisitDialogState();
}

class _AddVisitDialogState extends State<AddVisitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _uuid = const Uuid();

  String? _selectedCountryCode;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Visit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCountryCode,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                items: CountryUtils.getAllCountries()
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a country' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_startDate != null
                    ? _startDate!.toString().split(' ')[0]
                    : 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('End Date (optional)'),
                subtitle: Text(_endDate != null
                    ? _endDate!.toString().split(' ')[0]
                    : 'Ongoing'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  setState(() {
                    _endDate = date;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _selectedCountryCode != null) {
      final visit = Visit(
        id: _uuid.v4(),
        countryCode: _selectedCountryCode!,
        countryName: CountryUtils.getCountryName(_selectedCountryCode!),
        city: _cityController.text.isEmpty ? null : _cityController.text,
        startDate: _startDate!,
        endDate: _endDate,
        latitude: 0.0, // Manual entry - no coordinates
        longitude: 0.0,
        overnightOnly: false,
        isActive: _endDate == null,
        lastUpdated: DateTime.now(),
      );

      context.read<VisitsBloc>().add(VisitsEvent.createVisit(visit));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
        ),
      );
    }
  }
}
