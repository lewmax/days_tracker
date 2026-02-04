import 'dart:async';

import 'package:days_tracker/domain/entities/city.dart';
import 'package:flutter/material.dart';

/// A text field with async city autocomplete.
class CityAutocompleteField extends StatefulWidget {
  /// The currently selected city.
  final City? selectedCity;

  /// Callback when a city is selected.
  final void Function(City city) onCitySelected;

  /// Callback to search for cities.
  final Future<List<City>> Function(String query) onSearch;

  /// Label for the field.
  final String label;

  /// Error text to display.
  final String? errorText;

  /// Whether the field is enabled.
  final bool enabled;

  const CityAutocompleteField({
    super.key,
    this.selectedCity,
    required this.onCitySelected,
    required this.onSearch,
    this.label = 'City',
    this.errorText,
    this.enabled = true,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<City> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCity != null) {
      _controller.text = _formatCity(widget.selectedCity!);
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CityAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.selectedCity != null) {
          _controller.text = _formatCity(widget.selectedCity!);
        } else {
          _controller.clear();
        }
      });
    }
  }

  String _formatCity(City city) {
    return '${city.cityName}, ${city.country?.countryName ?? ''}';
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.length >= 2) {
        _searchCities(query);
      } else {
        _removeOverlay();
      }
    });
  }

  Future<void> _searchCities(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = await widget.onSearch(query);
      _suggestions = results;
      _showOverlay();
    } catch (e) {
      _suggestions = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    if (_suggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject() != null
            ? (context.findRenderObject()! as RenderBox).size.width
            : 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final city = _suggestions[index];
                  return ListTile(
                    title: Text(city.cityName),
                    subtitle: Text(city.country?.countryName ?? ''),
                    dense: true,
                    onTap: () {
                      _controller.text = _formatCity(city);
                      widget.onCitySelected(city);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: 'Type to search cities...',
          errorText: widget.errorText,
          prefixIcon: const Icon(Icons.location_city),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : widget.selectedCity != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _suggestions = [];
                    });
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: _onTextChanged,
      ),
    );
  }
}
