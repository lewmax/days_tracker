# Migration Notes

## Mapbox Package Update

The project now uses `mapbox_maps_flutter` (v2.3.0+) instead of the deprecated `mapbox_gl` package.

### What Changed

**Package:**
- Old: `mapbox_gl: ^0.16.0`
- New: `mapbox_maps_flutter: ^2.3.0`

**API Changes:**

1. **Map Widget**
   ```dart
   // Old (mapbox_gl)
   MapboxMap(
     accessToken: token,
     styleString: 'mapbox://styles/mapbox/streets-v11',
     initialCameraPosition: CameraPosition(
       target: LatLng(0, 0),
       zoom: 1,
     ),
     onMapCreated: (controller) { },
   )
   
   // New (mapbox_maps_flutter)
   MapWidget(
     resourceOptions: ResourceOptions(accessToken: token),
     cameraOptions: CameraOptions(
       center: Point(coordinates: Position(0, 0)),
       zoom: 1.0,
     ),
     styleUri: MapboxStyles.MAPBOX_STREETS,
     onMapCreated: (mapboxMap) { },
   )
   ```

2. **Markers/Annotations**
   ```dart
   // Old (mapbox_gl)
   controller.addSymbol(
     SymbolOptions(
       geometry: LatLng(lat, lng),
       iconImage: 'marker-15',
       iconSize: 1.5,
     ),
   )
   
   // New (mapbox_maps_flutter)
   final annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
   await annotationManager.createMulti([
     PointAnnotationOptions(
       geometry: Point(coordinates: Position(lng, lat)),
       iconSize: 1.5,
     ),
   ]);
   ```

3. **Coordinate Order**
   - **Important**: `mapbox_maps_flutter` uses **[longitude, latitude]** order (GeoJSON standard)
   - Old `mapbox_gl` used **[latitude, longitude]**
   - Make sure to swap coordinates when creating `Position(longitude, latitude)`

### Benefits of New Package

1. **Official Mapbox SDK**: Better support and updates
2. **Modern API**: Cleaner, more Flutter-friendly
3. **Better Performance**: Improved rendering and memory usage
4. **Active Development**: Regular updates and bug fixes
5. **Standard Compliance**: Uses GeoJSON coordinate order

### Migration Checklist

If you're updating from an older version:

- [ ] Update `pubspec.yaml` dependency
- [ ] Run `flutter pub get`
- [ ] Update map widget imports
- [ ] Update map initialization code
- [ ] Swap coordinate order (lat/lng → lng/lat)
- [ ] Update marker/annotation code
- [ ] Test map display and markers
- [ ] Verify token configuration

### Resources

- [mapbox_maps_flutter Documentation](https://pub.dev/packages/mapbox_maps_flutter)
- [Mapbox Maps SDK for Flutter](https://docs.mapbox.com/android/maps/guides/)
- [Migration Guide](https://docs.mapbox.com/android/maps/guides/migrate-to-v10/)

### Known Issues

1. **Token Configuration**: Make sure your Mapbox token is properly set in Settings
2. **Coordinate Order**: Double-check you're using [longitude, latitude] format
3. **Permissions**: Same location permissions required as before

### Testing

After migration, test:
- Map loads correctly
- Markers appear at correct locations
- Camera positioning works
- Token configuration in Settings
- Map styles load properly

---

For questions or issues with the Mapbox integration, see [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for detailed configuration.

