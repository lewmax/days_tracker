import 'package:days_tracker/core/utils/country_flag_utils.dart';
import 'package:flutter/material.dart';

/// Data class for a country option.
class CountryOption {
  final String code;
  final String name;

  const CountryOption({required this.code, required this.name});
}

/// A searchable dropdown for selecting a country.
class CountryPickerDropdown extends StatefulWidget {
  /// The currently selected country code.
  final String? selectedCountryCode;

  /// Callback when a country is selected.
  final void Function(CountryOption country) onCountrySelected;

  /// Label for the field.
  final String label;

  /// Error text to display.
  final String? errorText;

  const CountryPickerDropdown({
    super.key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.label = 'Country',
    this.errorText,
  });

  @override
  State<CountryPickerDropdown> createState() => _CountryPickerDropdownState();
}

class _CountryPickerDropdownState extends State<CountryPickerDropdown> {
  /// List of all countries (ISO 3166-1 alpha-2 codes).
  static const List<CountryOption> _countries = [
    CountryOption(code: 'AF', name: 'Afghanistan'),
    CountryOption(code: 'AL', name: 'Albania'),
    CountryOption(code: 'DZ', name: 'Algeria'),
    CountryOption(code: 'AD', name: 'Andorra'),
    CountryOption(code: 'AO', name: 'Angola'),
    CountryOption(code: 'AR', name: 'Argentina'),
    CountryOption(code: 'AM', name: 'Armenia'),
    CountryOption(code: 'AU', name: 'Australia'),
    CountryOption(code: 'AT', name: 'Austria'),
    CountryOption(code: 'AZ', name: 'Azerbaijan'),
    CountryOption(code: 'BS', name: 'Bahamas'),
    CountryOption(code: 'BH', name: 'Bahrain'),
    CountryOption(code: 'BD', name: 'Bangladesh'),
    CountryOption(code: 'BY', name: 'Belarus'),
    CountryOption(code: 'BE', name: 'Belgium'),
    CountryOption(code: 'BZ', name: 'Belize'),
    CountryOption(code: 'BJ', name: 'Benin'),
    CountryOption(code: 'BT', name: 'Bhutan'),
    CountryOption(code: 'BO', name: 'Bolivia'),
    CountryOption(code: 'BA', name: 'Bosnia and Herzegovina'),
    CountryOption(code: 'BW', name: 'Botswana'),
    CountryOption(code: 'BR', name: 'Brazil'),
    CountryOption(code: 'BN', name: 'Brunei'),
    CountryOption(code: 'BG', name: 'Bulgaria'),
    CountryOption(code: 'KH', name: 'Cambodia'),
    CountryOption(code: 'CM', name: 'Cameroon'),
    CountryOption(code: 'CA', name: 'Canada'),
    CountryOption(code: 'CL', name: 'Chile'),
    CountryOption(code: 'CN', name: 'China'),
    CountryOption(code: 'CO', name: 'Colombia'),
    CountryOption(code: 'CR', name: 'Costa Rica'),
    CountryOption(code: 'HR', name: 'Croatia'),
    CountryOption(code: 'CU', name: 'Cuba'),
    CountryOption(code: 'CY', name: 'Cyprus'),
    CountryOption(code: 'CZ', name: 'Czech Republic'),
    CountryOption(code: 'DK', name: 'Denmark'),
    CountryOption(code: 'DO', name: 'Dominican Republic'),
    CountryOption(code: 'EC', name: 'Ecuador'),
    CountryOption(code: 'EG', name: 'Egypt'),
    CountryOption(code: 'SV', name: 'El Salvador'),
    CountryOption(code: 'EE', name: 'Estonia'),
    CountryOption(code: 'ET', name: 'Ethiopia'),
    CountryOption(code: 'FI', name: 'Finland'),
    CountryOption(code: 'FR', name: 'France'),
    CountryOption(code: 'GE', name: 'Georgia'),
    CountryOption(code: 'DE', name: 'Germany'),
    CountryOption(code: 'GH', name: 'Ghana'),
    CountryOption(code: 'GR', name: 'Greece'),
    CountryOption(code: 'GT', name: 'Guatemala'),
    CountryOption(code: 'HN', name: 'Honduras'),
    CountryOption(code: 'HK', name: 'Hong Kong'),
    CountryOption(code: 'HU', name: 'Hungary'),
    CountryOption(code: 'IS', name: 'Iceland'),
    CountryOption(code: 'IN', name: 'India'),
    CountryOption(code: 'ID', name: 'Indonesia'),
    CountryOption(code: 'IR', name: 'Iran'),
    CountryOption(code: 'IQ', name: 'Iraq'),
    CountryOption(code: 'IE', name: 'Ireland'),
    CountryOption(code: 'IL', name: 'Israel'),
    CountryOption(code: 'IT', name: 'Italy'),
    CountryOption(code: 'JM', name: 'Jamaica'),
    CountryOption(code: 'JP', name: 'Japan'),
    CountryOption(code: 'JO', name: 'Jordan'),
    CountryOption(code: 'KZ', name: 'Kazakhstan'),
    CountryOption(code: 'KE', name: 'Kenya'),
    CountryOption(code: 'KW', name: 'Kuwait'),
    CountryOption(code: 'LV', name: 'Latvia'),
    CountryOption(code: 'LB', name: 'Lebanon'),
    CountryOption(code: 'LY', name: 'Libya'),
    CountryOption(code: 'LT', name: 'Lithuania'),
    CountryOption(code: 'LU', name: 'Luxembourg'),
    CountryOption(code: 'MY', name: 'Malaysia'),
    CountryOption(code: 'MV', name: 'Maldives'),
    CountryOption(code: 'MT', name: 'Malta'),
    CountryOption(code: 'MX', name: 'Mexico'),
    CountryOption(code: 'MD', name: 'Moldova'),
    CountryOption(code: 'MC', name: 'Monaco'),
    CountryOption(code: 'MN', name: 'Mongolia'),
    CountryOption(code: 'ME', name: 'Montenegro'),
    CountryOption(code: 'MA', name: 'Morocco'),
    CountryOption(code: 'NP', name: 'Nepal'),
    CountryOption(code: 'NL', name: 'Netherlands'),
    CountryOption(code: 'NZ', name: 'New Zealand'),
    CountryOption(code: 'NI', name: 'Nicaragua'),
    CountryOption(code: 'NG', name: 'Nigeria'),
    CountryOption(code: 'KP', name: 'North Korea'),
    CountryOption(code: 'MK', name: 'North Macedonia'),
    CountryOption(code: 'NO', name: 'Norway'),
    CountryOption(code: 'OM', name: 'Oman'),
    CountryOption(code: 'PK', name: 'Pakistan'),
    CountryOption(code: 'PA', name: 'Panama'),
    CountryOption(code: 'PY', name: 'Paraguay'),
    CountryOption(code: 'PE', name: 'Peru'),
    CountryOption(code: 'PH', name: 'Philippines'),
    CountryOption(code: 'PL', name: 'Poland'),
    CountryOption(code: 'PT', name: 'Portugal'),
    CountryOption(code: 'QA', name: 'Qatar'),
    CountryOption(code: 'RO', name: 'Romania'),
    CountryOption(code: 'RU', name: 'Russia'),
    CountryOption(code: 'SA', name: 'Saudi Arabia'),
    CountryOption(code: 'RS', name: 'Serbia'),
    CountryOption(code: 'SG', name: 'Singapore'),
    CountryOption(code: 'SK', name: 'Slovakia'),
    CountryOption(code: 'SI', name: 'Slovenia'),
    CountryOption(code: 'ZA', name: 'South Africa'),
    CountryOption(code: 'KR', name: 'South Korea'),
    CountryOption(code: 'ES', name: 'Spain'),
    CountryOption(code: 'LK', name: 'Sri Lanka'),
    CountryOption(code: 'SE', name: 'Sweden'),
    CountryOption(code: 'CH', name: 'Switzerland'),
    CountryOption(code: 'TW', name: 'Taiwan'),
    CountryOption(code: 'TH', name: 'Thailand'),
    CountryOption(code: 'TN', name: 'Tunisia'),
    CountryOption(code: 'TR', name: 'Turkey'),
    CountryOption(code: 'UA', name: 'Ukraine'),
    CountryOption(code: 'AE', name: 'United Arab Emirates'),
    CountryOption(code: 'GB', name: 'United Kingdom'),
    CountryOption(code: 'US', name: 'United States'),
    CountryOption(code: 'UY', name: 'Uruguay'),
    CountryOption(code: 'UZ', name: 'Uzbekistan'),
    CountryOption(code: 'VE', name: 'Venezuela'),
    CountryOption(code: 'VN', name: 'Vietnam'),
  ];

  CountryOption? _selectedCountry;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedCountryCode != null) {
      _selectedCountry = _countries.firstWhere(
        (c) => c.code == widget.selectedCountryCode,
        orElse: () => _countries.first,
      );
      _updateController();
    }
  }

  @override
  void didUpdateWidget(CountryPickerDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCountryCode != oldWidget.selectedCountryCode) {
      if (widget.selectedCountryCode != null) {
        _selectedCountry = _countries.firstWhere(
          (c) => c.code == widget.selectedCountryCode,
          orElse: () => _countries.first,
        );
      } else {
        _selectedCountry = null;
      }
      // Defer so we don't trigger Form setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateController();
      });
    }
  }

  void _updateController() {
    if (_selectedCountry != null) {
      final flag = CountryFlagUtils.getCountryFlag(_selectedCountry!.code);
      _controller.text = '$flag ${_selectedCountry!.name}';
    } else {
      _controller.text = '';
    }
  }

  Future<void> _showCountryPicker() async {
    final result = await showModalBottomSheet<CountryOption>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          _CountryPickerSheet(countries: _countries, selectedCode: _selectedCountry?.code),
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
        _updateController();
      });
      widget.onCountrySelected(result);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'Tap to select country',
        errorText: widget.errorText,
        prefixIcon: _selectedCountry != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  CountryFlagUtils.getCountryFlag(_selectedCountry!.code),
                  style: const TextStyle(fontSize: 24),
                ),
              )
            : const Icon(Icons.flag),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
      ),
      onTap: _showCountryPicker,
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final List<CountryOption> countries;
  final String? selectedCode;

  const _CountryPickerSheet({required this.countries, this.selectedCode});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late List<CountryOption> _filteredCountries;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        _filteredCountries = widget.countries
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search country...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterCountries,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected = country.code == widget.selectedCode;
                  final flag = CountryFlagUtils.getCountryFlag(country.code);

                  return ListTile(
                    leading: Text(flag, style: const TextStyle(fontSize: 28)),
                    title: Text(country.name),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    selected: isSelected,
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
