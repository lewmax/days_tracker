import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/usecases/geocoding/search_cities.dart';
import 'package:days_tracker/presentation/blocs/visit_form/visit_form.dart';
import 'package:days_tracker/presentation/common/bloc/screen_bloc_provider_stateless.dart';
import 'package:days_tracker/presentation/common/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Screen for adding a new visit.
@RoutePage()
final class AddVisitScreen extends ScreenBlocProviderStateless<VisitFormBloc, VisitFormState> {
  const AddVisitScreen({super.key});

  @override
  VisitFormBloc createBloc() {
    final bloc = locator<VisitFormBloc>();
    bloc.add(const VisitFormEvent.load(null));
    return bloc;
  }

  @override
  Widget buildScreen(BuildContext context, VisitFormBloc bloc) {
    return blocConsumer(
      listener: (context, state) {
        state.mapOrNull(
          saveSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.visitAddedSuccess)),
            );
            context.router.maybePop();
          },
        );
      },
      buildWhen: (prev, next) => prev != next,
      builder: (context, state) {
        return _AddVisitContent(bloc: bloc, state: state);
      },
    );
  }
}

class _AddVisitContent extends StatelessWidget {
  const _AddVisitContent({required this.bloc, required this.state});

  final VisitFormBloc bloc;
  final VisitFormState state;

  @override
  Widget build(BuildContext context) {
    if (state.mapOrNull(loadingVisit: (_) => true) == true) {
      return Scaffold(body: LoadingIndicator(message: context.l10n.loading));
    }

    final data = state.mapOrNull(form: (s) => s.data) ?? VisitFormData.empty();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addVisit)),
      body: Form(
        child: _AddVisitBody(bloc: bloc, data: data),
      ),
    );
  }
}

class _AddVisitBody extends StatelessWidget {
  const _AddVisitBody({required this.bloc, required this.data});

  final VisitFormBloc bloc;
  final VisitFormData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: data.isLocationLoading
              ? null
              : () => bloc.add(const VisitFormEvent.useCurrentLocation()),
          icon: data.isLocationLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(context.l10n.useCurrentLocation),
        ),
        const SizedBox(height: 24),
        CountryPickerDropdown(
          selectedCountryCode: data.countryCode,
          onCountrySelected: (c) => bloc.add(VisitFormEvent.setCountry(code: c.code, name: c.name)),
          label: context.l10n.countryLabel,
        ),
        const SizedBox(height: 16),
        CityAutocompleteField(
          selectedCity: data.city,
          onCitySelected: (city) => bloc.add(VisitFormEvent.setCity(city)),
          onSearch: _searchCities,
          label: context.l10n.cityLabel,
          enabled: data.countryCode != null,
        ),
        const SizedBox(height: 16),
        DateRangePickerField(
          startDate: data.startDate,
          endDate: data.endDate,
          onDatesSelected: (start, end) =>
              bloc.add(VisitFormEvent.setDates(start: start, end: end)),
          label: context.l10n.dateRangeLabel,
        ),
        const SizedBox(height: 24),
        if (data.errorMessage != null) ...[
          _ErrorBanner(message: data.errorMessage!),
          const SizedBox(height: 24),
        ],
        FilledButton(
          onPressed: data.isSaving
              ? null
              : () {
                  if (Form.maybeOf(context)?.validate() ?? false) {
                    bloc.add(const VisitFormEvent.save());
                  }
                },
          child: data.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(context.l10n.saveVisit),
        ),
      ],
    );
  }

  Future<List<City>> _searchCities(String query) async {
    final result = await locator<SearchCities>()(SearchCitiesParams(query: query));
    return result.fold((_) => <City>[], (cities) => cities);
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
