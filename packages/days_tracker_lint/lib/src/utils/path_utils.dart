/// Path-related utilities for lint rules.
class PathUtils {
  PathUtils._();

  /// Normalizes a file path for cross-platform comparison.
  static String normalize(String path) => path.replaceAll(r'\', '/');

  /// Returns true if the path is under a test directory.
  static bool isTestFile(String path) {
    return normalize(path).contains('/test/');
  }

  /// Returns true if the path is a generated file (.g.dart, .freezed.dart).
  static bool isGeneratedFile(String path) {
    final p = normalize(path);
    return p.endsWith('.g.dart') || p.endsWith('.freezed.dart');
  }

  /// Returns true if the path is in the domain layer (excludes test files).
  static bool isDomainFile(String path) {
    if (isTestFile(path)) return false;
    return normalize(path).contains('/domain/');
  }

  /// Returns true if the path is in the data layer (excludes test files).
  static bool isDataFile(String path) {
    if (isTestFile(path)) return false;
    return normalize(path).contains('/data/');
  }

  /// Returns true if the path is in the presentation layer (excludes test files).
  static bool isPresentationFile(String path) {
    if (isTestFile(path)) return false;
    return normalize(path).contains('/presentation/');
  }

  /// Returns true if the path is in the core layer (excludes test files).
  static bool isCoreFile(String path) {
    if (isTestFile(path)) return false;
    return normalize(path).contains('/core/');
  }

  /// Returns true if the path is in the repository layer (excludes test files).
  static bool isRepositoryFile(String path) {
    if (isTestFile(path)) return false;
    final p = normalize(path);
    return p.contains('/repositories/') ||
        p.contains('/data/repositories/') ||
        p.endsWith('_repo_impl.dart') ||
        p.endsWith('_repository_impl.dart');
  }

  /// Returns the architectural layer for the given path, or null if not in a layer.
  static String? getLayer(String path) {
    if (isTestFile(path)) return null;
    final p = normalize(path);
    if (p.contains('/domain/')) return 'domain';
    if (p.contains('/data/')) return 'data';
    if (p.contains('/presentation/')) return 'presentation';
    if (p.contains('/core/')) return 'core';
    return null;
  }

  /// Returns the feature name for files under presentation/features/X, or null.
  static String? getFeatureName(String path) {
    if (isTestFile(path)) return null;
    final match = RegExp('presentation/features/([^/]+)').firstMatch(normalize(path));
    return match?.group(1);
  }

  /// For presentation files: returns 'bloc' if path contains /bloc/ or /cubit/, else 'page'.
  /// Returns null for non-presentation files.
  static String? getPresentationSubLayer(String path) {
    if (!isPresentationFile(path)) return null;
    final p = normalize(path);
    if (p.contains('/bloc/') || p.contains('/cubit/')) return 'bloc';
    return 'page';
  }
}
