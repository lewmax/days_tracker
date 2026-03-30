/// Import-related utilities for lint rules.
class ImportUtils {
  ImportUtils._();

  /// Prefix for Flutter package imports (e.g. package:flutter/material.dart).
  static const String _flutterPackagePrefix = 'package:flutter/';

  /// Returns true if the URI is a Flutter import.
  static bool isFlutterImport(String uri) {
    return uri.startsWith(_flutterPackagePrefix);
  }

  /// Returns true if the URI is a Dart SDK import (dart:xxx).
  static bool isDartImport(String uri) {
    return uri.startsWith('dart:');
  }

  /// Extracts the path after package name from package:name/path.
  /// Returns null for dart: imports or if not a package import.
  static String? getPackagePath(String uri) {
    if (uri.startsWith('dart:')) return null;
    if (!uri.startsWith('package:')) return null;
    final slash = uri.indexOf('/', 8); // skip "package:"
    if (slash < 0) return null;
    return uri.substring(slash + 1);
  }

  /// Returns the target layer for same-package imports (domain, data, presentation, core).
  static String? getImportTargetLayer(String uri) {
    final path = getPackagePath(uri);
    if (path == null) return null;
    if (path.startsWith('domain/')) return 'domain';
    if (path.startsWith('data/')) return 'data';
    if (path.startsWith('presentation/')) return 'presentation';
    if (path.startsWith('core/')) return 'core';
    return null;
  }

  /// Returns the feature name for presentation/features/X imports, or null.
  static String? getImportTargetFeature(String uri) {
    final path = getPackagePath(uri);
    if (path == null) return null;
    final match = RegExp('^presentation/features/([^/]+)').firstMatch(path);
    return match?.group(1);
  }

  /// For presentation imports: returns 'bloc' if path contains /bloc/ or /cubit/, else 'page'.
  /// Returns null for non-presentation imports.
  static String? getImportTargetPresentationSubLayer(String uri) {
    final path = getPackagePath(uri);
    if (path == null || !path.startsWith('presentation/')) return null;
    if (path.contains('/bloc/') || path.contains('/cubit/')) return 'bloc';
    return 'page';
  }

  /// Returns true if the import targets the same package (path starts with a known layer).
  static bool isSamePackageImport(String uri) {
    final path = getPackagePath(uri);
    if (path == null) return false;
    return path.startsWith('domain/') ||
        path.startsWith('data/') ||
        path.startsWith('presentation/') ||
        path.startsWith('core/');
  }

  /// Packages allowed in domain layer (pure domain deps, no Flutter/data/presentation).
  static const _domainAllowedPackages = {
    'built_value',
    'collection',
    'crypto',
    'equatable',
    'freezed_annotation',
    'intl',
    'json_annotation',
    'meta',
    'uuid',
  };

  /// Returns true if the package import is allowed in the domain layer.
  static bool isAllowedInDomain(String uri) {
    if (isDartImport(uri)) return true;
    if (!uri.startsWith('package:')) return false;
    final slash = uri.indexOf('/', 8);
    if (slash < 0) return false;
    final package = uri.substring(8, slash);
    return _domainAllowedPackages.contains(package);
  }
}
