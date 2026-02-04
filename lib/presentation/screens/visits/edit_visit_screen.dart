import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/injection.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/usecases/geocoding/search_cities.dart';
import 'package:days_tracker/presentation/blocs/visit_form/visit_form.dart';
import 'package:days_tracker/presentation/common/bloc/screen_bloc_provider_stateless.dart';
import 'package:days_tracker/presentation/common/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Screen for editing an existing visit.
@RoutePage()
final class EditVisitScreen extends ScreenBlocProviderStateless<VisitFormBloc, VisitFormState> {
  const EditVisitScreen({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  VisitFormBloc createBloc() {
    final bloc = locator<VisitFormBloc>();
    bloc.add(VisitFormEvent.load(id));
    return bloc;
  }

  @override
  Widget buildScreen(BuildContext context, VisitFormBloc bloc) {
    return blocConsumer(
      listener: (context, state) {
        state.mapOrNull(
          saveSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.visitUpdatedSuccess)),
            );
            context.router.maybePop();
          },
        );
      },
      buildWhen: (prev, next) => prev != next,
      builder: (context, state) {
        return _EditVisitContent(bloc: bloc, state: state, visitId: id);
      },
    );
  }
}

class _EditVisitContent extends StatelessWidget {
  const _EditVisitContent({required this.bloc, required this.state, required this.visitId});

  final VisitFormBloc bloc;
  final VisitFormState state;
  final String visitId;

  @override
  Widget build(BuildContext context) {
    return state.map(
      initial: (_) => Scaffold(body: LoadingIndicator(message: context.l10n.loading)),
      loadingVisit: (_) => Scaffold(body: LoadingIndicator(message: context.l10n.loadingVisit)),
      loadError: (s) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.editVisit)),
        body: ErrorDisplayWidget(
          message: s.message,
          onRetry: () => bloc.add(VisitFormEvent.load(visitId)),
        ),
      ),
      form: (s) => _EditVisitForm(bloc: bloc, data: s.data),
      saveSuccess: (_) => const SizedBox.shrink(),
    );
  }
}

class _EditVisitForm extends StatelessWidget {
  const _EditVisitForm({required this.bloc, required this.data});

  final VisitFormBloc bloc;
  final VisitFormData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editVisit)),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CountryPickerDropdown(
              selectedCountryCode: data.countryCode,
              onCountrySelected: (c) =>
                  bloc.add(VisitFormEvent.setCountry(code: c.code, name: c.name)),
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
                  : Text(context.l10n.saveChanges),
            ),
          ],
        ),
      ),
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
