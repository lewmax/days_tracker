import 'package:days_tracker/l10n/s.dart';
import 'package:flutter/material.dart';

/// Extensions on [BuildContext] for convenient access to app resources.
extension BuildContextExt on BuildContext {
  /// Returns the current [S] localization.
  ///
  /// Throws [FlutterError] if localization is not found (e.g. [S.delegate]
  /// is missing from [localizationsDelegates]).
  S get l10n {
    final localization = S.of(this);
    if (localization == null) {
      throw FlutterError(
        'S localization not found in context. '
        'Make sure S.delegate is included in localizationsDelegates.',
      );
    }
    return localization;
  }
}
