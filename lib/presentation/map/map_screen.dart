import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/di/locator.dart';
import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/presentation/common/widgets/error_widget.dart';
import 'package:days_tracker/presentation/common/widgets/loading_widget.dart';
import 'package:days_tracker/presentation/map/bloc/map_bloc.dart';
import 'package:days_tracker/presentation/map/bloc/map_event.dart';
import 'package:days_tracker/presentation/map/bloc/map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

@RoutePage()
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<MapBloc>()..add(const MapEvent.loadMapData()),
      child: const _MapScreenContent(),
    );
  }
}

class _MapScreenContent extends StatefulWidget {
  const _MapScreenContent();

  @override
  State<_MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<_MapScreenContent> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return state.when(
            initial: () => const LoadingWidget(),
            loading: () => const LoadingWidget(),
            loaded: (
              visits,
              visitedCountries,
              countryCities,
              selectedCountry,
              selectedCity,
            ) =>
                Stack(
              children: [
                _buildMap(context, visits),
                _buildLegend(context, visitedCountries),
              ],
            ),
            error: (message) => ErrorDisplayWidget(
              message: message,
              onRetry: () {
                context.read<MapBloc>().add(const MapEvent.loadMapData());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, List<Visit> visits) {
    // TODO: Replace with actual Mapbox token from settings
    const String mapboxToken = 'YOUR_MAPBOX_TOKEN_HERE';
    
    MapboxOptions.setAccessToken(mapboxToken);
    return MapWidget(
      key: const ValueKey('mapWidget'),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(0, 0)),
        zoom: 1.0,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: (mapboxMap) {
        _mapboxMap = mapboxMap;
        _addVisitMarkers(visits);
      },
    );
  }

  Future<void> _addVisitMarkers(List<Visit> visits) async {
    if (_mapboxMap == null) return;

    try {
      // Create point annotation manager
      _pointAnnotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();

      // Add markers for each visit
      final pointAnnotations = visits.map((visit) {
        return PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(visit.longitude, visit.latitude),
          ),
          iconSize: 1.5,
        );
      }).toList();

      await _pointAnnotationManager?.createMulti(pointAnnotations);
    } catch (e) {
      // Ignore errors for markers
      debugPrint('Error adding markers: $e');
    }
  }

  Widget _buildLegend(BuildContext context, Set<String> visitedCountries) {
    if (visitedCountries.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visited Countries (${visitedCountries.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visitedCountries.map((code) {
                  return Chip(
                    label: Text(
                      CountryUtils.getCountryName(code),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pointAnnotationManager?.deleteAll();
    super.dispose();
  }
}
